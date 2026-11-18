import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET


FIELDS = {
    'schema': str, 'owner': str, 'authority': str, 'override_rule': str, 'purpose': str,
    'http_bind_host': str, 'http_port': int, 'ssh_bind_host': str, 'ssh_port': int,
    'launcher_url': str, 'runtime_process': str, 'stop_with_task': bool,
    'foreground_service_type': str, 'new_host_allowlist': bool, 'new_origin_allowlist': bool,
    'new_command_allowlist': bool, 'new_path_allowlist': bool, 'new_authentication_gate': bool,
    'arbitrary_execution_deadlines': bool, 'forced_framework_or_provider_swap': bool,
    'preserve_headless_lifecycle': bool, 'preserve_existing_sessions': bool,
    'existing_ssh_authentication': str, 'existing_bounded_operations': str,
    'verification_scope': str, 'format': str, 'preflight1_default_enabled': bool,
    'preflight1_readiness': str, 'preflight1_override': str, 'semantic_rag_bind_host': str, 'semantic_rag_port': int
}
JAVA_ROOT = Path('server-java/teec/shell/term_shell/runtime')
SOURCE_FILES = [JAVA_ROOT / name for name in ['TerminalServer.java', 'UbuntuRuntimeService.java', 'UbuntuRuntime.java', 'UbuntuSsh.java', 'RagPreflight.java', 'SemanticRag.java']]
INPUT_FILES = [Path('server-java/runtime-policy.yaml'), Path('AndroidManifest.xml'), *SOURCE_FILES]
TOKEN = re.compile(r'(?P<space>\s+)|(?P<line>//[^\n]*)|(?P<block>/\*.*?\*/)|(?P<string>"(?:\\.|[^"\\])*")|(?P<char>\x27(?:\\.|[^\x27\\])*\x27)|(?P<word>[A-Za-z_$][A-Za-z0-9_$]*)|(?P<number>0[xX][0-9a-fA-F]+|[0-9]+)|(?P<symbol>.)', re.DOTALL)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_policy(path):
    values = {}
    for number, line in enumerate(path.read_text().splitlines(), 1):
        if not line.strip():
            continue
        match = re.fullmatch(r'([a-z][a-z0-9_]*): (.+)', line)
        require(match is not None, f'Unsupported flat YAML syntax at line {number}')
        key, text = match.groups()
        require(key in FIELDS, f'Unknown policy key: {key}')
        require(key not in values, f'Duplicate policy key: {key}')
        try:
            value = json.loads(text)
        except json.JSONDecodeError as error:
            raise ValueError(f'Unsupported YAML scalar for {key}: {error.msg}') from error
        require(type(value) is FIELDS[key], f'Wrong policy type for {key}')
        if isinstance(value, str):
            require(bool(value.strip()), f'Empty policy value: {key}')
        values[key] = value
    require(set(values) == set(FIELDS), 'Missing policy keys: ' + ', '.join(sorted(set(FIELDS) - set(values))))
    require(values['schema'] == 'teec.runtime-owner-policy/1', 'Unsupported runtime policy schema')
    require(values['authority'] == 'explicit_user_instruction', 'Runtime policy must retain explicit user authority')
    for key in ['http_port', 'ssh_port', 'semantic_rag_port']:
        require(0 < values[key] < 65536, f'Invalid port in {key}')
    return values


def tokens(path):
    return [match.group() for match in TOKEN.finditer(path.read_text()) if match.lastgroup not in {'space', 'line', 'block'}]


def replace_tokens(text, before, after):
    source = [match for match in TOKEN.finditer(text) if match.lastgroup not in {'space', 'line', 'block'}]
    pattern = [match.group() for match in TOKEN.finditer(before) if match.lastgroup not in {'space', 'line', 'block'}]
    starts = [index for index in range(len(source) - len(pattern) + 1) if [match.group() for match in source[index:index + len(pattern)]] == pattern]
    require(len(starts) == 1, 'Isolated probe needs exactly one matching token sequence: ' + before)
    start = starts[0]
    return text[:source[start].start()] + after + text[source[start + len(pattern) - 1].end():]


def matches(source, pattern):
    found = []
    for index in range(len(source) - len(pattern) + 1):
        selected = source[index:index + len(pattern)]
        if all(expected is None or expected == actual for expected, actual in zip(pattern, selected)):
            found.append([actual for expected, actual in zip(pattern, selected) if expected is None])
    return found


def single_value(source, pattern, label):
    found = matches(source, pattern)
    require(len(found) == 1 and len(found[0]) == 1, f'{label}: expected exactly one supported declaration')
    return found[0][0]


def string_value(token, label):
    try:
        value = json.loads(token)
    except json.JSONDecodeError as error:
        raise ValueError(f'{label}: expected a string literal; update this narrow check if an authorized refactor changes its form') from error
    require(type(value) is str, f'{label}: expected a string literal')
    return value


def verify(root):
    policy = read_policy(root / 'server-java/runtime-policy.yaml')
    sources = {path.name: tokens(root / path) for path in SOURCE_FILES}
    checks = []

    def equal(label, actual, expected):
        require(actual == expected, f'{label}: expected {expected!r}, found {actual!r}')
        checks.append({'id': label, 'observed': actual})

    server = sources['TerminalServer.java']
    bind = single_value(server, ['listener', '.', 'bind', '(', 'new', 'InetSocketAddress', '(', None, ',', 'port', ')', ')'], 'http_bind_host')
    equal('http_bind_host', string_value(bind, 'http_bind_host'), policy['http_bind_host'])
    service = sources['UbuntuRuntimeService.java']
    port = single_value(service, ['new', 'TerminalServer', '(', None, ','], 'http_port')
    equal('http_port', int(port, 0), policy['http_port'])
    ssh_port = single_value(sources['UbuntuSsh.java'], ['public', 'static', 'final', 'int', 'PORT', '=', None, ';'], 'ssh_port')
    equal('ssh_port', int(ssh_port, 0), policy['ssh_port'])
    ssh_bind = single_value(service, ['"-p"', ',', None, '+', 'UbuntuSsh', '.', 'PORT', ','], 'ssh_bind_host')
    equal('ssh_bind_host', string_value(ssh_bind, 'ssh_bind_host'), policy['ssh_bind_host'] + ':')
    require(bool(matches(service, ['proot', '.', 'command', '(', '"/usr/sbin/dropbear"', ','])), 'SSH launch must still use the checked Dropbear command')
    runtime = sources['UbuntuRuntime.java']
    url = single_value(runtime, ['public', 'static', 'final', 'String', 'URL', '=', None, ';'], 'launcher_url')
    equal('launcher_url', string_value(url, 'launcher_url'), policy['launcher_url'])
    browser = single_value(runtime, ['new', 'Intent', '(', 'Intent', '.', 'ACTION_VIEW', ',', 'Uri', '.', 'parse', '(', None, ')', ')'], 'launcher_uses_policy_url')
    equal('launcher_uses_policy_url', browser, 'URL')
    require(len(matches(service, ['new', 'Intent', '(', 'Intent', '.', 'ACTION_VIEW', ',', 'android', '.', 'net', '.', 'Uri', '.', 'parse', '(', 'UbuntuRuntime', '.', 'URL', ')', ')'])) == 1, 'Notification launcher must use UbuntuRuntime.URL')
    checks.append({'id': 'notification_uses_policy_url', 'observed': 'UbuntuRuntime.URL'})
    preflight = sources['RagPreflight.java']
    default = single_value(preflight, ['public', 'static', 'final', 'boolean', 'DEFAULT_ENABLED', '=', None, ';'], 'preflight1_default_enabled')
    equal('preflight1_default_enabled', default == 'true', policy['preflight1_default_enabled'])
    rag = sources['SemanticRag.java']
    rag_port = single_value(rag, ['public', 'static', 'final', 'int', 'PORT', '=', None, ';'], 'semantic_rag_port')
    equal('semantic_rag_port', int(rag_port, 0), policy['semantic_rag_port'])
    rag_bind = single_value(rag, ['"--host"', ',', None, ',', '"--port"'], 'semantic_rag_bind_host')
    equal('semantic_rag_bind_host', string_value(rag_bind, 'semantic_rag_bind_host'), policy['semantic_rag_bind_host'])
    manifest = ET.parse(root / 'AndroidManifest.xml').getroot()
    namespace = '{http://schemas.android.com/apk/res/android}'
    services = [node for node in manifest.findall('application/service') if node.get(namespace + 'name') == 'teec.shell.term_shell.runtime.UbuntuRuntimeService']
    require(len(services) == 1, 'Expected exactly one Ubuntu runtime service in the manifest')
    for attribute, key in [('process', 'runtime_process'), ('stopWithTask', 'stop_with_task'), ('foregroundServiceType', 'foreground_service_type')]:
        expected = str(policy[key]).lower() if type(policy[key]) is bool else policy[key]
        equal(key, services[0].get(namespace + attribute), expected)
    return {'schema': 'teec.runtime-owner-policy-check/1', 'status': 'passed', 'owner': policy['owner'], 'checks': checks, 'scope': policy['verification_scope']}


def self_test(root, include_positive=True):
    probes = []
    originals = {path: (root / path).read_text() for path in INPUT_FILES}
    build_path = Path('tools/build-server-java.py')
    check_path = Path('.github/scripts/verify-runtime-policy.py')
    with tempfile.TemporaryDirectory(prefix='teec-policy-') as temporary:
        work = Path(temporary)
        for relative in [build_path, check_path]:
            (work / relative).parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(root / relative, work / relative)

        def reset():
            for path, text in originals.items():
                (work / path).parent.mkdir(parents=True, exist_ok=True)
                (work / path).write_text(text)

        def reject(name, relative, before, after):
            reset()
            target = work / relative
            target.write_text(replace_tokens(target.read_text(), before, after))
            try:
                verify(work)
            except (ValueError, OSError, ET.ParseError) as error:
                probes.append({'id': name, 'status': 'rejected', 'reason': str(error)})
            else:
                raise ValueError(f'Policy gate accepted negative probe: {name}')

        reject('preflight-default-bypass', SOURCE_FILES[4], 'boolean DEFAULT_ENABLED = true;', 'boolean DEFAULT_ENABLED = false;')
        reject('rag-loopback', SOURCE_FILES[5], '"--host", "0.0.0.0", "--port"', '"--host", "127.0.0.1", "--port"')
        reject('rag-port-change', SOURCE_FILES[5], 'int PORT = 8867;', 'int PORT = 8868;')
        reject('http-loopback', SOURCE_FILES[0], 'new InetSocketAddress("0.0.0.0", port)', 'new InetSocketAddress("127.0.0.1", port)')
        reject('http-port-change', SOURCE_FILES[1], 'new TerminalServer(8866,', 'new TerminalServer(8867,')
        reject('ssh-loopback', SOURCE_FILES[1], '"0.0.0.0:" + UbuntuSsh.PORT', '"127.0.0.1:" + UbuntuSsh.PORT')
        reject('ssh-port-change', SOURCE_FILES[3], 'int PORT = 8122;', 'int PORT = 8123;')
        reject('launcher-loopback', SOURCE_FILES[2], 'String URL = "http://0.0.0.0:8866/terminal";', 'String URL = "http://127.0.0.1:8866/terminal";')
        reject('launcher-bypasses-constant', SOURCE_FILES[2], 'Uri.parse(URL)', 'Uri.parse("http://127.0.0.1:8866/terminal")')
        reject('notification-bypasses-constant', SOURCE_FILES[1], 'android.net.Uri.parse(UbuntuRuntime.URL)', 'android.net.Uri.parse("http://127.0.0.1:8866/terminal")')
        reject('boolean-port-rejected', Path('server-java/runtime-policy.yaml'), 'http_port: 8866', 'http_port: true')
        reject('duplicate-policy-key', Path('server-java/runtime-policy.yaml'), 'http_port: 8866', 'http_port: 8866\nhttp_port: 8866')
        reject('unsupported-yaml-nesting', Path('server-java/runtime-policy.yaml'), 'http_port: 8866', 'http_port:\n  value: 8866')
        reset()
        manifest_path = work / 'AndroidManifest.xml'
        tree = ET.parse(manifest_path)
        namespace = '{http://schemas.android.com/apk/res/android}'
        service = next(node for node in tree.getroot().findall('application/service') if node.get(namespace + 'name') == 'teec.shell.term_shell.runtime.UbuntuRuntimeService')
        service.set(namespace + 'stopWithTask', 'true')
        tree.write(manifest_path, encoding='unicode')
        try:
            verify(work)
        except ValueError as error:
            probes.append({'id': 'headless-task-removal-regression', 'status': 'rejected', 'reason': str(error)})
        else:
            raise ValueError('Policy gate accepted stopWithTask=true')
        if include_positive:
            reset()
            server = work / SOURCE_FILES[0]
            server.write_text(replace_tokens(server.read_text(), 'listener.bind(new InetSocketAddress("0.0.0.0", port));', 'listener . bind ( new InetSocketAddress ( "0.0.0.0" , port ) );'))
            runtime = work / SOURCE_FILES[2]
            runtime.write_text(replace_tokens(runtime.read_text(), 'public final class UbuntuRuntime {', 'public final class UbuntuRuntime {\n    private static final int UNRELATED_PROBE = 7;'))
            verify(work)
            nested = self_test(work, include_positive=False)
            probes.append({'id': 'whitespace-and-unrelated-source-improvement', 'status': 'accepted', 'complete_negative_preflight_probes': len(nested['probes'])})
        reset()
        runtime = work / SOURCE_FILES[2]
        runtime.write_text(replace_tokens(runtime.read_text(), 'String URL = "http://0.0.0.0:8866/terminal";', 'String URL = "http://127.0.0.1:8866/terminal";'))
        result = subprocess.run([sys.executable, str(work / build_path)], text=True, capture_output=True)
        failure = json.loads(result.stdout)
        require(result.returncode != 0 and failure.get('status') == 'failed' and 'launcher_url' in failure.get('error', ''), 'Java build did not reject the launcher policy violation before compilation')
        require(not (work / 'server-java/build.json').exists(), 'Negative preflight generated Java build output')
        probes.append({'id': 'java-build-stops-before-compilation', 'status': 'rejected', 'exit_code': result.returncode})
    return {'status': 'passed', 'probes': probes, 'scratch_removed': True, 'runtime_mutations': False}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument('--self-test', action='store_true')
    options = parser.parse_args()
    try:
        result = verify(options.root)
        if options.self_test:
            result['self_test'] = self_test(options.root)
    except (ValueError, OSError, ET.ParseError) as error:
        print(json.dumps({'schema': 'teec.runtime-owner-policy-check/1', 'status': 'failed', 'error': str(error)}))
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
