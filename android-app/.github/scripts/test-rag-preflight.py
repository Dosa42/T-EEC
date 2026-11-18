import argparse
import asyncio
import hashlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import platform
import shutil
import struct
import subprocess
import tempfile
import threading
import time
import urllib.error
import urllib.request
import websockets
from host_java_dependencies import json_classpath

parser = argparse.ArgumentParser()
parser.add_argument('--evidence', type=Path)
parser.add_argument('--live-rag-url')
options = parser.parse_args()
root = Path(__file__).resolve().parents[2]
runtime = root / 'server-java/teec/shell/term_shell/runtime'
checks = []
health = {'ready': False, 'error': 'startup_selftest_pending'}
requests = []


def require(value, label):
    if not value:
        raise AssertionError(label)
    checks.append(label)


class RagHandler(BaseHTTPRequestHandler):
    def log_message(self, *arguments):
        pass

    def do_GET(self):
        requests.append(('GET', self.path))
        result = dict(health)
        if self.path.startswith('/events'):
            result = {'cursor': 19, 'events': [{'seq': 19, 'kind': 'inference'}], 'snapshot': dict(health)}
        payload = json.dumps(result).encode()
        self.send_response(200)
        self.send_header('Content-Length', str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_POST(self):
        body = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        requests.append(('POST', self.path, json.loads(body or b'{}')))
        if '/models/' in self.path:
            time.sleep(1.4)
        payload = json.dumps({'accepted': True, 'path': self.path}).encode()
        self.send_response(202 if self.path == '/selftest' else 200)
        self.send_header('Content-Length', str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


async def check(port, process):
    base = 'http://127.0.0.1:' + str(port)

    def api(path, method='GET', body=None):
        request = urllib.request.Request(base + path, data=None if body is None else json.dumps(body).encode(), method=method)
        try:
            response = urllib.request.urlopen(request, timeout=8)
        except urllib.error.HTTPError as failure:
            response = failure
        with response:
            payload = response.read()
            return response.status, json.loads(payload) if response.headers.get('Content-Type', '').startswith('application/json') else payload.decode()

    async def until(client, marker):
        output = ''
        while marker not in output:
            message = await asyncio.wait_for(client.recv(), 8)
            if isinstance(message, bytes):
                position = struct.unpack('>Q', message[:8])[0]
                output += message[8:].decode(errors='replace')
                await client.send('ack:' + str(position))
        return output

    async def state(client, allowed):
        while True:
            message = await asyncio.wait_for(client.recv(), 8)
            if isinstance(message, bytes):
                await client.send('ack:' + str(struct.unpack('>Q', message[:8])[0]))
            else:
                result = json.loads(message)
                if result.get('type') == 'state' and result['preflight']['terminal_allowed'] == allowed:
                    return result

    def setting(enabled):
        process.stdin.write('Preflight1: ' + str(enabled).lower() + '\n')
        process.stdin.flush()
        line = process.stdout.readline()
        require(line.startswith('SETTING=') and ('Preflight1: ' + str(enabled).lower()) in line, 'native_setting_' + str(enabled).lower())

    status, blocked = api('/sessions', 'POST')
    require(status == 503 and not blocked['preflight']['terminal_allowed'] and not blocked['running'], 'default_enabled_denies_creation')
    require(api('/terminal')[0] == 200, 'blocked_diagnostics_remain_available')
    status, events = api('/control/rag/events?after=17')
    require(status == 200 and events['cursor'] == 19 and ('GET', '/events?after=17') in requests, 'event_cursor_query_preserved')
    endpoint = 'ws://127.0.0.1:' + str(port) + '/ws'
    async with websockets.connect(endpoint) as client:
        blocked_state = await state(client, False)
        require(not blocked_state['running'], 'blocked_websocket_recovers_without_pty')
        await client.send(b"printf 'PREMATURE\\n'\n")
        health.update(ready=True, error='')
        await asyncio.sleep(.6)
        status, created = api('/sessions', 'POST')
        require(status == 201 and created['preflight']['terminal_allowed'] and created['running'], 'healthy_allows_creation')
        pid = created['pid']
        await until(client, 'RAG_PROMPT>')
        await client.send(b'stty -echo\n')
        await until(client, 'RAG_PROMPT>')
        await client.send(b"printf 'JOB_BEGIN\\n'; sleep 1; printf 'JOB_SURVIVED\\n'\n")
        await until(client, 'JOB_BEGIN')
        health.update(ready=False, error='selftest_failed')
        await asyncio.sleep(.6)
        await state(client, False)
        await client.send(b"printf 'REJECTED_INPUT\\n'\n")
        output = await until(client, 'JOB_SURVIVED')
        require('REJECTED_INPUT' not in output and api('/health')[1]['pid'] == pid, 'readiness_loss_preserves_running_command_and_pid')
        require(api('/sessions', 'POST')[0] == 503, 'readiness_loss_denies_new_sessions')
        setting(False)
        status, bypass = api('/control/rag/status')
        require(not bypass['ready'] and not bypass['preflight']['enabled'] and bypass['preflight']['terminal_allowed'], 'explicit_owner_bypass_visible')
        await client.send(b"printf 'BYPASS_OK\\n'\n")
        output = await until(client, 'BYPASS_OK')
        require('REJECTED_INPUT' not in output, 'blocked_bytes_never_reach_shell')
        setting(True)
        require(not api('/control/rag/status')[1]['preflight']['terminal_allowed'], 'reenable_restores_gate_immediately')
        await client.send(b"printf 'REENABLE_REJECTED\\n'\n")
        await state(client, False)
        health.update(ready=True, error='')
        await asyncio.sleep(.6)
        await client.send(b"printf 'RESTORED_OK\\n'\n")
        output = await until(client, 'RESTORED_OK')
        require('REENABLE_REJECTED' not in output and api('/health')[1]['pid'] == pid, 'health_reauthorizes_same_session')
    status, result = api('/control/rag/selftest', 'POST', {})
    require(status == 200 and result['upstream_status'] == 202, 'selftest_proxy_acknowledges_async_start')
    status, result = api('/control/rag/models/e5/run', 'POST', {'text': 'probe'})
    require(status == 200 and result['upstream_status'] == 200 and ('POST', '/models/e5/run', {'text': 'probe'}) in requests, 'inference_proxy_exceeds_health_timeout_without_cancellation')
    require(api('/control/rag/preflight', 'POST', {'enabled': False})[0] == 500 and api('/control/rag/status')[1]['preflight']['enabled'], 'no_remote_toggle')
    health.clear()
    await asyncio.sleep(.6)
    require(not api('/control/rag/status')[1]['preflight']['terminal_allowed'], 'missing_readiness_fails_closed')
    require(api('/health')[1]['running'], 'websocket_close_keeps_pty')


with tempfile.TemporaryDirectory(prefix='teec-rag-gate-') as temporary:
    work = Path(temporary)
    classpath = json_classpath(root, work)
    names = ['PtyNative.java', 'PtySession.java', 'TerminalServer.java', 'TerminalSessions.java', 'McpEndpoint.java', 'FileWorkspace.java', 'SemanticRag.java', 'RagPreflight.java', 'SemanticSettings.java', 'ProotCommand.java', 'UbuntuImage.java']
    fixtures = ['android/content/Context.java', 'android/content/res/AssetManager.java', 'android/content/pm/ApplicationInfo.java']
    subprocess.run(['javac', '--release', '8', '-Xlint:-options', '-cp', classpath, '-d', work, *[runtime / name for name in names], *[root / 'tests/java' / name for name in fixtures], root / 'tests/pty/RagPreflightTestMain.java'], check=True)
    android = Path('/system/bin/linker64').is_file() and platform.machine() == 'aarch64'
    if android:
        shutil.copy2(root / 'lib/arm64-v8a/libteec_pty.so', work / 'libteec_pty.so')
    else:
        java_home = Path(shutil.which('javac')).resolve().parents[1]
        subprocess.run(['cc', '-shared', '-fPIC', '-O2', '-I' + str(java_home / 'include'), '-I' + str(java_home / 'include/linux'), root / 'native/pty.c', '-o', work / 'libteec_pty.so'], check=True)
    server = ThreadingHTTPServer(('127.0.0.1', 0), RagHandler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    shell = '/data/data/com.termux/files/usr/bin/bash' if android else '/bin/bash'
    process = subprocess.Popen(['java', '-Djava.library.path=' + str(work), '-cp', classpath, 'RagPreflightTestMain', work / 'settings', root / 'assets', 'http://127.0.0.1:' + str(server.server_port), shell], stdout=subprocess.PIPE, stdin=subprocess.PIPE, text=True)
    try:
        line = process.stdout.readline().strip()
        require(line.startswith('PORT='), 'settings_persistence_invalid_failures_strict_ready_and_deploy_preservation_passed')
        asyncio.run(check(int(line.split('=')[1]), process))
    finally:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
        server.shutdown()
        server.server_close()
    if options.live_rag_url:
        result = subprocess.run(['java', '-cp', classpath, 'RagPreflightTestMain', work / 'live-settings', root / 'assets', options.live_rag_url], check=True, capture_output=True, text=True)
        admission = json.loads(result.stdout)
        require(admission == {'enabled': True, 'terminal_allowed': True, 'reason': 'rag_ready'}, 'actual_service_readiness_allows_default_enabled_java_gate')

report = {'schema': 'teec.rag-preflight-tests/1', 'status': 'passed', 'checks': checks, 'count': len(checks), 'sources': {str((runtime / name).relative_to(root)): hashlib.sha256((runtime / name).read_bytes()).hexdigest() for name in names}, 'limitations': ['RAG responses are controlled fixtures; real model readiness is tested by the semantic service suite.', 'Android Messenger WRITE is compiled and reviewed; host fixture exercises the shared gate through real PTYs and WebSockets.', 'No application restart, install, or live guest mutation.']}
if options.evidence:
    options.evidence.parent.mkdir(parents=True, exist_ok=True)
    options.evidence.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'status': report['status'], 'checks': len(checks)}))
