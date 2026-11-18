import argparse
import hashlib
from http.client import HTTPConnection
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import urllib.parse

from host_java_dependencies import json_classpath, json_jar

parser = argparse.ArgumentParser()
parser.add_argument('--evidence', type=Path)
options = parser.parse_args()
root = Path(__file__).resolve().parents[2]
runtime = root / 'server-java/teec/shell/term_shell/runtime'
checks = []
versions = ['2025-11-25', '2025-06-18']


def require(condition, label, detail=None):
    if not condition:
        raise AssertionError((label, detail))
    checks.append(label)


with tempfile.TemporaryDirectory(prefix='teec-mcp-test-') as temporary:
    work = Path(temporary)
    classpath = json_classpath(root, work)
    names = ['PtyNative.java', 'PtySession.java', 'TerminalServer.java', 'FileWorkspace.java', 'MachineEngine.java', 'McpEndpoint.java']
    subprocess.run(['javac', '--release', '8', '-Xlint:-options', '-cp', classpath, '-d', work, *[runtime / name for name in names], root / 'tests/pty/MachineEngineTestMain.java'], check=True)
    directory = work / 'persistent'
    cwd = work / 'cwd unicode ✓ & + %'
    cwd.mkdir()
    shell = str(Path(os.environ['PREFIX']) / 'bin/bash') if Path('/system/bin/linker64').exists() else '/bin/bash'
    process = None
    port = None
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json, text/event-stream', 'MCP-Protocol-Version': versions[0]}

    def start():
        global process, port
        process = subprocess.Popen(['java', '-cp', classpath, 'MachineEngineTestMain', directory], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        line = process.stdout.readline().strip()
        if not line.startswith('PORT='):
            raise RuntimeError('MCP test server did not start: ' + line + process.stderr.read())
        port = int(line.split('=')[1])
        require(port != 8866, 'isolated_ephemeral_port')

    def stop():
        process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()

    def http(method='POST', path='/mcp', body=b'', supplied=None, chunked=False):
        connection = HTTPConnection('127.0.0.1', port, timeout=10)
        try:
            connection.request(method, path, body=body, headers=headers if supplied is None else supplied, encode_chunked=chunked)
            response = connection.getresponse()
            data = response.read()
            return response.status, dict((key.lower(), value) for key, value in response.getheaders()), data
        finally:
            connection.close()

    def rpc(method, params=None, identifier=1, supplied=None, chunked=False):
        request = {'jsonrpc': '2.0', 'method': method}
        if identifier is not None:
            request['id'] = identifier
        if params is not None:
            request['params'] = params
        body = json.dumps(request, ensure_ascii=False).encode()
        status, response_headers, data = http(body=[body[:7], body[7:]] if chunked else body, supplied=supplied, chunked=chunked)
        return status, response_headers, json.loads(data) if data else None

    def call(name, arguments=None):
        status, response_headers, result = rpc('tools/call', {'name': name, 'arguments': arguments or {}})
        require(status == 200 and 'result' in result, 'tool_rpc_' + name, result)
        tool = result['result']
        require(tool['content'][0]['type'] == 'text' and json.loads(tool['content'][0]['text']) == tool['structuredContent'], 'structured_text_parity_' + name, tool)
        return tool

    def order(identifier):
        result = call('engine_order', {'id': identifier})
        require(not result['isError'], 'order_read_' + identifier, result)
        return result['structuredContent']

    def done(identifier):
        deadline = time.monotonic() + 15
        while time.monotonic() < deadline:
            result = order(identifier)
            if result['status'] in ['done', 'failed', 'interrupted']:
                return result
            time.sleep(.03)
        raise RuntimeError(identifier + ' did not finish')

    def submit(identifier, argv):
        return call('engine_submit', {'id': identifier, 'source': 'mcp-test ✓ + &', 'cwd': str(cwd), 'argv': argv})

    try:
        start()
        for version in versions + ['2025-03-26', '2099-01-01']:
            status, response_headers, result = rpc('initialize', {'protocolVersion': version, 'capabilities': {}, 'clientInfo': {'name': 'host-test', 'version': '1'}}, supplied={'Content-Type': 'application/json', 'Accept': headers['Accept']})
            expected = version if version in versions else versions[0]
            require(status == 200 and result['result']['protocolVersion'] == expected, 'version_negotiation_' + version, result)
            require(response_headers['mcp-protocol-version'] == expected and response_headers['content-type'].startswith('application/json'), 'negotiated_response_headers_' + version)
            require(result['result']['capabilities'] == {'tools': {'listChanged': False}} and 'mcp-session-id' not in response_headers, 'stateless_tools_capability_' + version)
        status, response_headers, result = rpc('notifications/initialized', identifier=None)
        require(status == 202 and result is None and response_headers['content-length'] == '0', 'initialized_notification_202_empty')
        status, _, result = rpc('ping', identifier='unicode ✓ id\n"')
        require(status == 200 and result == {'jsonrpc': '2.0', 'id': 'unicode ✓ id\n"', 'result': {}}, 'ping_exact_id')
        status, response_headers, result = rpc('ping', supplied={'Content-Type': 'application/json', 'Accept': headers['Accept']})
        require(status == 400 and result['error']['code'] == -32600, 'missing_version_header_unsupported_legacy_default')
        for method in ['GET', 'HEAD', 'DELETE', 'PUT']:
            status, response_headers, data = http(method=method)
            require(status == 405 and response_headers['allow'] == 'POST' and data == b'', 'no_sse_' + method)
        for changed, expected in [({'MCP-Protocol-Version': 'future'}, 400), ({'Content-Type': 'text/plain'}, 415), ({'Accept': 'text/event-stream'}, 406), ({'Accept': 'application/json;q=0, text/event-stream'}, 406)]:
            status, _, _ = rpc('ping', supplied=dict(headers, **changed))
            require(status == expected, 'transport_header_' + str(changed), status)
        status, _, _ = rpc('ping', supplied=dict(headers, Host='custom-host.example:8866', Origin='https://custom-origin.example'))
        require(status == 200, 'existing_unrestricted_host_origin_policy_preserved')
        status, _, result = rpc('ping', chunked=True)
        require(status == 200 and result['result'] == {}, 'chunked_post')
        status, _, result = rpc('tools/list')
        tools = result['result']['tools']
        require(status == 200 and [item['name'] for item in tools] == ['engine_status', 'engine_submit', 'engine_order'], 'minimal_three_tool_catalog')
        require(all(item['inputSchema']['type'] == 'object' and item['inputSchema']['additionalProperties'] is False for item in tools), 'object_input_schemas')
        require(tools[1]['inputSchema']['required'] == ['id', 'source', 'cwd', 'argv'], 'submit_required_fields')
        before = call('engine_status')['structuredContent']
        require(before['orderCount'] == 0 and before['latest'] is None and 'orders' not in before, 'empty_compact_status')
        invalid_json = [b'{', b'{} trailing', b'{"jsonrpc":"2.0",}', b"{'jsonrpc':'2.0'}", b'{"n":01}', b'{"n":NaN}', b'{"a":"\x01"}', b'{"a":"\xff"}', b'{"a":undefined}', b'{"a":1;"b":2}', '{"a":"\\u１２３４"}'.encode()]
        for body in invalid_json:
            status, _, data = http(body=body)
            require(status == 400 and json.loads(data)['error']['code'] == -32700 and 'id' not in json.loads(data), 'invalid_json_' + repr(body), data)
        for payload in [[], [{}], 3, None, {'jsonrpc': '1.0', 'id': 3, 'method': 'ping'}, {'jsonrpc': '2.0', 'id': None, 'method': 'ping'}, {'jsonrpc': '2.0', 'id': True, 'method': 'ping'}, {'jsonrpc': '2.0', 'id': 1.5, 'method': 'ping'}, {'jsonrpc': '2.0', 'id': 1, 'method': 42}]:
            status, _, data = http(body=json.dumps(payload).encode())
            require(status == 400 and json.loads(data)['error']['code'] == -32600, 'invalid_envelope_' + repr(payload), data)
        for method, params in [('initialize', {}), ('tools/list', {'cursor': 'missing'}), ('tools/call', {'name': 'missing'}), ('tools/call', {'name': 'engine_status', 'arguments': []}), ('tools/call', [])]:
            status, _, result = rpc(method, params)
            require(status == 200 and result['error']['code'] == -32602, 'invalid_params_' + repr(params), result)
        for name, arguments in [('engine_status', {'unknown': 1}), ('engine_order', {'id': 5}), ('engine_order', {}), ('engine_submit', {'id': 'invalid', 'source': 'test', 'cwd': '.', 'argv': [shell]}), ('engine_submit', {'id': 'invalid', 'source': 'test', 'cwd': str(cwd), 'argv': [shell, 5]}), ('engine_submit', {'id': 'invalid', 'source': 'test', 'cwd': str(cwd), 'argv': []})]:
            result = call(name, arguments)
            require(result['isError'] and result['structuredContent']['error'], 'invalid_tool_arguments_' + repr(arguments), result)
        status, _, result = rpc('missing/method')
        require(status == 200 and result['error']['code'] == -32601, 'unknown_method')
        status, _, _ = rpc('tools/call', {'name': 'engine_submit', 'arguments': {'id': 'notification-not-executed', 'source': 'test', 'cwd': str(cwd), 'argv': [shell, '-c', 'touch NOTIFICATION_EXECUTED']}}, identifier=None)
        require(status == 202 and not (cwd / 'NOTIFICATION_EXECUTED').exists() and call('engine_status')['structuredContent']['orderCount'] == 0, 'notifications_do_not_execute_orders')
        response_message = {'jsonrpc': '2.0', 'id': 'client-response', 'result': {}}
        status, _, data = http(body=json.dumps(response_message).encode())
        require(status == 202 and not data, 'client_response_202_empty')
        require(call('engine_order', {'id': 'unknown'})['isError'], 'missing_order_is_tool_error')
        literal = "literal ; $(touch INJECTED) ' ✓ + & %\nline"
        identifier = 'exact / ✓ + & % %2F ?query=value#fragment'
        argv = [shell, '-c', 'printf "%s\\n" "$PWD" "$1" "$2"; printf stderr >&2', 'mcp-test', literal, '']
        accepted = submit(identifier, argv)
        require(not accepted['isError'] and accepted['structuredContent']['argv'] == argv, 'accepted_exact_argv')
        result = done(identifier)
        require(result['stdout'] == str(cwd) + '\n' + literal + '\n\n' and result['stderr'] == 'stderr' and result['exit'] == '0', 'exact_cwd_unicode_empty_arg_stdout_stderr_exit', result)
        require(result['source'] == 'mcp-test ✓ + &' and not (cwd / 'INJECTED').exists(), 'source_literal_not_shell_interpreted')
        duplicate = submit(identifier, [shell, '-c', 'touch DUPLICATE'])
        require(duplicate['isError'] and not (cwd / 'DUPLICATE').exists() and order(identifier)['argv'] == argv, 'duplicate_id_original_preserved')
        submit('command-failed', [shell, '-c', 'printf failed >&2; exit 7'])
        result = done('command-failed')
        require(result['status'] == 'failed' and result['exit'] == '7' and result['stderr'] == 'failed', 'failed_process_record')
        submit('exec-failed', [str(cwd / 'missing-command')])
        result = done('exec-failed')
        require(result['status'] == 'failed' and (result['error'] or result['stderr']), 'missing_executable_record')
        submit('unrelated', [shell, '-c', 'printf unrelated'])
        done('unrelated')
        record = next(path for path in directory.glob('*.order') if '\nid=unrelated\n' in path.read_text())
        stdout = Path(str(record) + '.stdout')
        kept = Path(str(stdout) + '.kept')
        stdout.rename(kept)
        stdout.symlink_to('/proc/self/mem')
        try:
            status, _, _ = http(method='GET', path='/control/status')
            require(status == 500, 'unrelated_output_poison_proves_history_read_failure')
            compact = call('engine_status')['structuredContent']
            require(compact['orderCount'] == 4 and 'stdout' not in json.dumps(compact) and len(json.dumps(compact)) < 1024, 'compact_status_avoids_unrelated_output')
            require(order(identifier)['stdout'].endswith(literal + '\n\n'), 'single_order_avoids_unrelated_output')
        finally:
            stdout.unlink()
            kept.rename(stdout)
        status, _, data = http(method='GET', path='/control/orders/' + urllib.parse.quote(identifier, safe=''))
        require(status == 200 and json.loads(data)['id'] == identifier, 'single_order_control_route')
        for path in ['/health', '/sessions', '/control/status', '/control/summary']:
            status, _, data = http(method='GET', path=path)
            require(status == 200 and isinstance(json.loads(data), dict), 'existing_http_route_' + path)
        status, _, _ = http(method='GET', path='/control/missing')
        require(status == 500, 'existing_control_error_semantics')
        submit('interrupt', [shell, '-c', 'printf started >> starts; while test ! -f release; do sleep .05; done; printf completed'])
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline and not (cwd / 'starts').exists():
            time.sleep(.02)
        require((cwd / 'starts').read_text() == 'started' and order('interrupt')['status'] == 'running', 'interrupt_order_started_once')
        stop()
        (cwd / 'release').touch()
        start()
        result = order('interrupt')
        require(result['status'] == 'interrupted' and (cwd / 'starts').read_text() == 'started', 'interrupted_not_replayed_after_restart', result)
        duplicate = submit('interrupt', [shell, '-c', 'printf duplicated >> starts'])
        require(duplicate['isError'] and (cwd / 'starts').read_text() == 'started', 'interrupted_id_not_reused')
        require(order(identifier)['argv'] == argv and order(identifier)['stdout'].endswith(literal + '\n\n'), 'completed_order_persists_restart')
        result = {'schema': 'teec.mcp-host-test/1', 'passed': True, 'checks': checks, 'count': len(checks), 'live_8866_touched': False, 'protocol_versions': versions, 'tool_names': [item['name'] for item in tools], 'json_dependency_sha256': hashlib.sha256(json_jar(root).read_bytes()).hexdigest(), 'sources': {str((runtime / name).relative_to(root)): hashlib.sha256((runtime / name).read_bytes()).hexdigest() for name in names}, 'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
        if options.evidence:
            options.evidence.parent.mkdir(parents=True, exist_ok=True)
            options.evidence.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
        print(json.dumps({'passed': True, 'checks': len(checks), 'tools': result['tool_names'], 'live_8866_touched': False}))
    finally:
        (cwd / 'release').touch()
        if process is not None and process.poll() is None:
            stop()
