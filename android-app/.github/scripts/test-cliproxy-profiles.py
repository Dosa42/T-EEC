import argparse
import copy
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


harness = '''import teec.shell.term_shell.runtime.CliProxyProfiles;
import teec.shell.term_shell.runtime.TerminalServer;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.CountDownLatch;

public final class CliProxyProfilesTest {
    public static void main(String[] arguments) throws Exception {
        CliProxyProfiles profiles = new CliProxyProfiles(new File(arguments[0]));
        TerminalServer.Provider provider = new TerminalServer.Provider() {
            public TerminalServer.State current() { return new TerminalServer.State("", null, ""); }
            public TerminalServer.Admission admission() { return new TerminalServer.Admission(true, false, "test_gate_closed"); }
        };
        TerminalServer server = new TerminalServer(0, path -> { throw new IOException("No assets"); }, provider, null, profiles::request);
        Runtime.getRuntime().addShutdownHook(new Thread(server::close));
        System.out.println("PORT=" + server.port());
        System.out.flush();
        new CountDownLatch(1).await();
    }
}
'''

with tempfile.TemporaryDirectory(prefix='teec-cliproxy-profiles-') as temporary:
    work = Path(temporary)
    fixture = work / 'CliProxyProfilesTest.java'
    fixture.write_text(harness)
    file = work / 'client-profiles.json'
    classpath = json_classpath(root, work)
    names = ['PtyNative.java', 'PtySession.java', 'TerminalServer.java', 'McpEndpoint.java', 'FileWorkspace.java', 'CliProxyProfiles.java']
    subprocess.run(['javac', '--release', '8', '-Xlint:-options', '-cp', classpath, '-d', work, *[runtime / name for name in names], fixture], check=True)
    process = subprocess.Popen(['java', '-cp', classpath, 'CliProxyProfilesTest', file], stdout=subprocess.PIPE, text=True)
    try:
        line = process.stdout.readline().strip()
        require(line.startswith('PORT='), 'real_terminal_http_server_started')
        port = int(line.split('=')[1])

        def http(path='/control/cliproxy/profiles', method='GET'):
            connection = HTTPConnection('127.0.0.1', port, timeout=8)
            try:
                connection.request(method, path)
                response = connection.getresponse()
                return response.status, dict(response.getheaders()), response.read()
            finally:
                connection.close()

        def write(value):
            file.write_text(json.dumps(value, ensure_ascii=False), encoding='utf-8')

        def fails(label, path='/control/cliproxy/profiles', method='GET'):
            code, headers, data = http(path, method)
            require(code == 500 and bool(data), label + '_explicit_error')
            require(headers.get('Cache-Control') == 'no-store', label + '_uncached')
            require(all(secret.encode() not in data for secret in secrets), label + '_no_key_in_error')

        secrets = ['fixture-key-chat', 'fixture-key-responses', 'fixture-key-messages', 'fixture-key-generate']
        document = {
            'schema': 'synthetic-client-profiles/1',
            'base_url': 'http://0.0.0.0:8317',
            'upstream_provider': 'codex',
            'terminal_connected': False,
            'profiles': [
                {'name': name, 'endpoint': endpoint, 'header': header, 'api_key': key, 'reused_existing_key': False}
                for name, endpoint, header, key in zip(
                    ['openai-chat', 'openai-responses', 'anthropic', 'gemini'],
                    ['/v1/chat/completions', '/v1/responses', '/v1/messages', '/v1beta/models'],
                    ['Authorization: Bearer', 'Authorization: Bearer', 'x-api-key', 'x-goog-api-key'], secrets
                )
            ]
        }
        code, headers, data = http()
        require(code == 200 and json.loads(data) == {'configured': False, 'profiles': []}, 'missing_file_empty_state')
        require(not file.exists(), 'missing_file_never_created')
        fails('missing_file_reveal', '/control/cliproxy/profiles/openai-chat')
        write(document)
        original = file.read_bytes()
        code, headers, data = http()
        result = json.loads(data)
        require(code == 200 and result['configured'] is True and len(result['profiles']) == 4, 'four_profile_metadata_available_with_closed_preflight')
        require(headers.get('Cache-Control') == 'no-store', 'metadata_uncached')
        require(result['base_url'] == document['base_url'] and result['upstream_provider'] == 'codex', 'connection_metadata_preserved')
        require(set(result) == {'configured', 'base_url', 'upstream_provider', 'profiles'}, 'list_top_level_fields_only')
        require(all(set(item) == {'name', 'endpoint', 'header', 'has_key'} and item['has_key'] is True for item in result['profiles']), 'metadata_fields_only')
        require(all(secret.encode() not in data for secret in secrets) and b'api_key' not in data, 'metadata_omits_all_key_values_and_fields')
        for profile in document['profiles']:
            code, headers, data = http('/control/cliproxy/profiles/' + quote(profile['name'], safe=''))
            require(code == 200 and json.loads(data) == {'name': profile['name'], 'api_key': profile['api_key']}, 'reveal_exact_' + profile['name'])
            require(headers.get('Cache-Control') == 'no-store', 'reveal_uncached_' + profile['name'])
            require(all(secret.encode() not in data for secret in secrets if secret != profile['api_key']), 'reveal_no_other_keys_' + profile['name'])
        require(file.read_bytes() == original, 'profile_reads_do_not_mutate_file')
        fails('unknown_profile', '/control/cliproxy/profiles/not-present')
        fails('empty_profile_name', '/control/cliproxy/profiles/')
        fails('unknown_route', '/control/cliproxy/unknown')
        fails('post_list_rejected', method='POST')
        fails('post_reveal_rejected', '/control/cliproxy/profiles/openai-chat', 'POST')
        require(file.read_bytes() == original, 'invalid_requests_do_not_mutate_file')
        unusual = copy.deepcopy(document)
        unusual['profiles'][0].update(name='Türkçe 資料 +/%2F?#', api_key='  fixture-ö漢字-🔑-"\\\n  ')
        write(unusual)
        code, headers, data = http('/control/cliproxy/profiles/' + quote(unusual['profiles'][0]['name'], safe=''))
        require(code == 200 and json.loads(data) == {'name': unusual['profiles'][0]['name'], 'api_key': unusual['profiles'][0]['api_key']}, 'encoded_name_decoded_once_and_key_preserves_unicode_whitespace')
        changed = copy.deepcopy(document)
        changed['profiles'][0]['api_key'] = 'fixture-key-updated'
        write(changed)
        code, headers, data = http('/control/cliproxy/profiles/openai-chat')
        require(code == 200 and json.loads(data)['api_key'] == 'fixture-key-updated', 'reveal_reads_current_file_without_cached_secret')
        for missing in ['absent', 'empty', 'null']:
            value = copy.deepcopy(document)
            if missing == 'absent':
                del value['profiles'][0]['api_key']
            else:
                value['profiles'][0]['api_key'] = '' if missing == 'empty' else None
            write(value)
            code, headers, data = http()
            require(code == 200 and json.loads(data)['profiles'][0]['has_key'] is False, missing + '_key_reported_unavailable')
            fails(missing + '_key_reveal', '/control/cliproxy/profiles/openai-chat')
        malformed = [
            [], {}, {'base_url': 3, 'upstream_provider': 'codex', 'profiles': []},
            {'base_url': 'http://example.invalid', 'upstream_provider': 'codex', 'profiles': {}},
            {**document, 'profiles': [False]},
            {**document, 'profiles': [{'name': 'broken', 'endpoint': '/', 'header': 3, 'api_key': secrets[0]}]},
            {**document, 'profiles': [{**document['profiles'][0], 'api_key': 42}]},
            {**document, 'profiles': [document['profiles'][0], document['profiles'][0]]},
            {**document, 'profiles': [{**document['profiles'][0], 'name': ''}]}
        ]
        for index, value in enumerate(malformed):
            write(value)
            fails('malformed_structure_' + str(index))
        for label, data in [('broken_json', ('{"profiles": [' + secrets[0]).encode()), ('trailing_data', json.dumps(document).encode() + secrets[0].encode()), ('invalid_utf8', b'{"profiles": "\xff"}')]:
            file.write_bytes(data)
            fails(label)
        file.unlink()
        file.mkdir()
        fails('unreadable_profile_file')
    finally:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()

sources = [runtime / name for name in ['CliProxyProfiles.java', 'UbuntuRuntimeService.java', 'TerminalServer.java']] + [Path(__file__).resolve()]
report = {'schema': 'teec.cliproxy-profile-tests/1', 'status': 'passed', 'count': len(checks), 'checks': checks, 'sources': {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in sources}, 'limitations': ['Synthetic profile files through the real TerminalServer HTTP handler; no production credentials read.', 'No APK build, installation, live service restart or provider attachment.']}
if options.evidence:
    options.evidence.parent.mkdir(parents=True, exist_ok=True)
    options.evidence.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'status': 'passed', 'checks': len(checks)}))
