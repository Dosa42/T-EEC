import argparse
import hashlib
from http.client import HTTPConnection
import json
from pathlib import Path
import subprocess
import tempfile
from urllib.parse import quote
from host_java_dependencies import json_classpath

parser = argparse.ArgumentParser()
parser.add_argument('--evidence', type=Path)
options = parser.parse_args()
root = Path(__file__).resolve().parents[2]
runtime = root / 'server-java/teec/shell/term_shell/runtime'
checks = []


def require(condition, label):
    if not condition:
        raise AssertionError(label)
    checks.append(label)


harness = '''import teec.shell.term_shell.runtime.FrontendAssets;
import teec.shell.term_shell.runtime.TerminalServer;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.concurrent.CountDownLatch;

public final class ExternalFrontendTest {
    public static void main(String[] arguments) throws Exception {
        TerminalServer.Assets bundled = path -> {
            try (FileInputStream input = new FileInputStream(new File(arguments[1], path)); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
                byte[] buffer = new byte[16384];
                int count;
                while ((count = input.read(buffer)) != -1) output.write(buffer, 0, count);
                return output.toByteArray();
            }
        };
        FrontendAssets assets = new FrontendAssets(new File(arguments[0]), bundled);
        TerminalServer.Provider provider = new TerminalServer.Provider() {
            public TerminalServer.State current() { return new TerminalServer.State("test", null, ""); }
            public TerminalServer.Admission admission() { return new TerminalServer.Admission(true, false, "test_gate_closed"); }
        };
        TerminalServer server = new TerminalServer(0, assets, provider, null, (method, path, body) -> "{\\"route\\":\\"control\\"}");
        Runtime.getRuntime().addShutdownHook(new Thread(server::close));
        System.out.println("PORT=" + server.port());
        System.out.flush();
        new CountDownLatch(1).await();
    }
}
'''

with tempfile.TemporaryDirectory(prefix='teec-external-frontend-') as temporary:
    work = Path(temporary)
    external = work / 'frontend'
    fixture = work / 'ExternalFrontendTest.java'
    fixture.write_text(harness)
    classpath = json_classpath(root, work)
    names = ['PtyNative.java', 'PtySession.java', 'TerminalServer.java', 'McpEndpoint.java', 'FileWorkspace.java', 'FrontendAssets.java']
    subprocess.run(['javac', '--release', '8', '-Xlint:-options', '-cp', classpath, '-d', work, *[runtime / name for name in names], fixture], check=True)
    process = subprocess.Popen(['java', '-cp', classpath, 'ExternalFrontendTest', external, root / 'assets'], stdout=subprocess.PIPE, text=True)
    try:
        line = process.stdout.readline().strip()
        require(line.startswith('PORT='), 'real_terminal_server_started')
        port = int(line.split('=')[1])

        def http(path, method='GET'):
            connection = HTTPConnection('127.0.0.1', port, timeout=8)
            try:
                connection.request(method, path)
                response = connection.getresponse()
                return response.status, dict(response.getheaders()), response.read()
            finally:
                connection.close()

        bundled_index = (root / 'assets/terminal/index.html').read_bytes()
        code, headers, data = http('/terminal/index.html')
        require(code == 200 and data == bundled_index, 'absent_external_directory_uses_packaged_frontend')
        require(not external.exists(), 'reading_frontend_never_creates_or_seeds_directory')
        external.mkdir()
        index = external / 'index.html'
        index.write_bytes(b'<html>owner first version</html>')
        for path in ['/', '/terminal', '/terminal/', '/terminal/index.html']:
            code, headers, data = http(path)
            require(code == 200 and data == index.read_bytes() and headers['Content-Type'] == 'text/html; charset=utf-8', 'external_index_alias_' + path)
        owner_bytes = b'<html>owner live edit without server restart</html>'
        index.write_bytes(owner_bytes)
        code, headers, data = http('/terminal/index.html?version=2')
        require(code == 200 and data == owner_bytes and headers['Cache-Control'] == 'no-store', 'next_request_reads_live_edit_without_restart_or_rebuild')
        require(index.read_bytes() == owner_bytes, 'server_preserves_owner_edit')
        code, headers, data = http('/terminal/index.html', 'HEAD')
        require(code == 200 and data == b'' and int(headers['Content-Length']) == len(owner_bytes), 'head_preserves_length_without_body')
        code, headers, data = http('/terminal/app.js')
        require(code == 200 and data == (root / 'assets/terminal/app.js').read_bytes(), 'missing_external_file_falls_back_individually')
        index.unlink()
        code, headers, data = http('/terminal/index.html')
        require(code == 200 and data == bundled_index and not index.exists(), 'external_removal_restores_fallback_without_recreating_file')
        (external / 'new/nested').mkdir(parents=True)
        formats = [('module.mjs', 'text/javascript'), ('theme.css', 'text/css'), ('data.json', 'application/json'), ('icon.svg', 'image/svg+xml'), ('image.PNG', 'image/png'), ('face.woff2', 'font/woff2'), ('face.ttf', 'font/ttf'), ('runtime.wasm', 'application/wasm'), ('unknown.payload', 'application/octet-stream')]
        for name, mime in formats:
            binary = mime in ['image/png', 'font/woff2', 'font/ttf', 'application/wasm', 'application/octet-stream']
            payload = b'\x00\xff\x80\x01' if binary else ('fixture ' + name).encode()
            (external / 'new/nested' / name).write_bytes(payload)
            code, headers, data = http('/terminal/new/nested/' + name)
            require(code == 200 and data == payload and headers['Content-Type'].split(';')[0] == mime, 'new_nested_asset_without_filename_list_' + name)
            if binary:
                require('charset=' not in headers['Content-Type'], 'binary_mime_without_text_encoding_' + name)
        encoded_name = 'Türkçe 資料 +%2F.json'
        (external / encoded_name).write_text('{"live":true}', encoding='utf-8')
        code, headers, data = http('/terminal/' + quote(encoded_name, safe=''))
        require(code == 200 and json.loads(data) == {'live': True}, 'unicode_and_percent_encoded_asset_name_decoded_once')
        for path in ['/terminal/missing.js', '/terminal/new/nested/', '/outside', '/terminal/%2e%2e/outside', '/terminal/%2Fetc/passwd']:
            code, headers, data = http(path)
            require(code == 404, 'invalid_or_missing_static_asset_' + path)
        code, headers, data = http('/terminal/missing.js', 'HEAD')
        require(code == 404 and data == b'', 'missing_asset_head_has_no_body')
        code, headers, data = http('/control/probe')
        require(code == 200 and json.loads(data) == {'route': 'control'}, 'control_dispatch_still_precedes_static_dispatch')
        code, headers, data = http('/health')
        require(code == 200 and json.loads(data)['preflight']['terminal_allowed'] is False, 'health_and_closed_preflight_unchanged')
        code, headers, data = http('/sessions', 'POST')
        require(code == 503, 'terminal_creation_remains_blocked_by_closed_preflight')
        code, headers, data = http('/terminal/new/nested/theme.css', 'POST')
        require(code == 404, 'static_post_does_not_modify_assets')
    finally:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()

sources = [runtime / name for name in ['FrontendAssets.java', 'UbuntuRuntimeService.java', 'TerminalServer.java']] + [Path(__file__).resolve()]
report = {'schema': 'teec.external-frontend-tests/1', 'status': 'passed', 'count': len(checks), 'checks': checks, 'sources': {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in sources}, 'limitations': ['Uses an isolated directory and host TerminalServer; Android live deployment is verified separately.', 'No production frontend files, services or settings modified.']}
if options.evidence:
    options.evidence.parent.mkdir(parents=True, exist_ok=True)
    options.evidence.write_text(json.dumps(report, separators=(',', ':')) + '\n')
print(json.dumps({'status': 'passed', 'checks': len(checks)}))
