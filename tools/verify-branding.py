import ast
import argparse
import hashlib
import json
import os
import re
import struct
import sys
import tarfile
import zipfile
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

import jsonschema


ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'android-app'
ANDROID = '{http://schemas.android.com/apk/res/android}'
GENERATED_ROOTS = ('.git', 'build', 'dist', 'evidence', 'android-app/build',
                   'android-app/dist', 'android-app/evidence', 'android-app/.gradle')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def source_paths():
    for directory, names, files in os.walk(ROOT, followlinks=False):
        base = Path(directory)
        relative = base.relative_to(ROOT)
        for name in list(names):
            item = (relative / name).as_posix()
            generated = item in GENERATED_ROOTS or (name == '__pycache__' and 'assets' not in relative.parts)
            if generated:
                names.remove(name)
        for name in sorted(names + files):
            yield base / name


def load_contract(portable=False):
    identity = json.loads((ROOT / 'identity.json').read_text())
    schema = json.loads((ROOT / 'tools/identity.schema.json').read_text())
    jsonschema.Draft202012Validator.check_schema(schema)
    jsonschema.Draft202012Validator(schema).validate(identity)
    checks = json.loads((ROOT / identity['verification']['current_source']).read_text())
    check_schema = json.loads((ROOT / 'tools/current-source-checks.schema.json').read_text())
    jsonschema.Draft202012Validator.check_schema(check_schema)
    jsonschema.Draft202012Validator(check_schema).validate(checks)
    if portable:
        return identity, None, checks
    rules = json.loads((ROOT / identity['history']['verification_rules']).read_text())
    text_type = {'type': 'string', 'minLength': 1}
    words = {'type': 'object', 'required': ['path', 'word'], 'additionalProperties': False,
             'properties': {'path': text_type, 'word': text_type}}
    pattern = {'type': 'object', 'required': ['id', 'pattern'], 'additionalProperties': False,
               'properties': {'id': text_type, 'pattern': text_type,
                              'allowed_paths': {'type': 'array', 'items': text_type},
                              'allowed_words': {'type': 'array', 'items': words}}}
    missing = {'type': 'object', 'required': ['before', 'after'], 'additionalProperties': False,
               'properties': {'before': text_type, 'after': text_type}}
    rule_schema = {'type': 'object', 'required': ['schema_version', 'patterns', 'inherited_missing_classes'],
                   'additionalProperties': False, 'properties': {
                       'schema_version': {'const': 1},
                       'patterns': {'type': 'array', 'minItems': 1, 'items': pattern},
                       'inherited_missing_classes': {'type': 'array', 'items': missing}}}
    jsonschema.Draft202012Validator.check_schema(rule_schema)
    jsonschema.Draft202012Validator(rule_schema).validate(rules)
    return identity, rules, checks


def scan_names(rules=None):
    patterns = [(item['id'], re.compile(item['pattern'].encode(), re.I), item.get('allowed_paths', []), item.get('allowed_words', []))
                for item in rules['patterns']] if rules is not None else []
    exceptions = Counter()
    violations = []
    counts = Counter()

    def inspect(path, value, category):
        for key, pattern, allowed, words in patterns:
            if not pattern.search(value):
                continue
            if any(re.fullmatch(expression, path) for expression in allowed):
                exceptions[key] += 1
            else:
                for match in pattern.finditer(value):
                    if any(re.fullmatch(item['path'], path) and re.match(item['word'].encode(), value[match.start():], re.I) for item in words):
                        exceptions[key + '-language'] += 1
                    else:
                        violations.append(f'{category}: {path} [{key}]')

    for path in sorted(source_paths()):
        relative = path.relative_to(ROOT).as_posix()
        inspect(relative, relative.encode(), 'name')
        require(not path.is_symlink(), f'Unexpected shared symlink: {relative}')
        if not path.is_file():
            continue
        counts['files'] += 1
        if path.name.endswith(('.zip', '.jar', '.ja')):
            with zipfile.ZipFile(path) as archive:
                for member in archive.infolist():
                    target = relative + '!' + member.filename
                    inspect(target, member.filename.encode(), 'member name')
                    if not member.is_dir():
                        inspect(target, archive.read(member), 'member content')
                        counts['archive_members'] += 1
        elif path.name.endswith(('.tar.gz', '.tar.xz', '.tar')):
            with tarfile.open(path, 'r:*') as archive:
                for member in archive:
                    target = relative + '!' + member.name
                    inspect(target, member.name.encode(), 'member name')
                    if member.issym() or member.islnk():
                        inspect(target, member.linkname.encode(), 'member link')
                    if member.isfile():
                        inspect(target, archive.extractfile(member).read(), 'member content')
                        counts['archive_members'] += 1
        else:
            inspect(relative, path.read_bytes(), 'content')
    require(not violations, 'Unexpected application identity references:\n' + '\n'.join(violations[:50]))
    scope = 'name/content scan' if rules is not None else 'source/archive readability and symlink isolation'
    print(f'PASS {scope}: {counts["files"]} files, {counts["archive_members"]} expanded archive members')
    if rules is not None:
        print('INFO retained third-party matches: ' + json.dumps(dict(exceptions), sort_keys=True))


def android_identity(identity):
    manifest = ET.parse(APP / 'AndroidManifest.xml').getroot()
    app = manifest.find('application')
    require(manifest.get('package') == identity['application']['id'], 'Android application ID mismatch')
    require(manifest.get(ANDROID + 'sharedUserId') is None, 'Shared Android UID requested')
    require(app.get(ANDROID + 'label') == '@string/app_name', 'Application label binding mismatch')
    authorities = [node.get(ANDROID + 'authorities') for node in app.findall('provider')]
    require(authorities == [identity['application']['id'] + '.lifecycle-process'], 'Provider authority mismatch')
    for path in APP.glob('res/values*/strings.xml'):
        name = ET.parse(path).getroot().find("string[@name='app_name']")
        require(name is None or name.text == identity['application']['label'], f'Application label mismatch: {path}')
    receiver = app.find("receiver[@" + ANDROID + "name='" + identity['java']['launcher_receiver'] + "']")
    require(receiver is not None, 'Launcher receiver is absent')
    actions = [node.get(ANDROID + 'name') for node in receiver.findall('intent-filter/action')]
    expected = [identity['application']['id'] + '.' + item for item in ('top_or_left', 'bottom_or_right', 'freeform', 'maintainOnScreen')]
    require(actions == expected, 'Launcher action mismatch')
    apktool = (APP / 'apktool.yml').read_text()
    require('apkFileName: teec.apk' in apktool, 'APK output name mismatch')
    print('PASS Android ID, provider, labels, launcher actions and output name')


def current_missing_classes(unresolved, content_by_path, checks):
    exceptions = checks['unresolved_owned_classes']
    require(unresolved == {item['class'] for item in exceptions}, f'Unexpected unresolved application classes: {sorted(unresolved)}')
    for item in exceptions:
        descriptor = 'L' + item['class'] + ';'
        actual = {path for path, content in content_by_path.items() if descriptor in content}
        expected = {entry['path'] for entry in item['referrers']}
        require(actual == expected, f'Unresolved-class referrer scope changed: {item["class"]}')
        for entry in item['referrers']:
            content = content_by_path[entry['path']]
            require(content.count(descriptor) == entry['references'], f'Unresolved-class reference count changed: {entry["path"]}')
            require(hashlib.sha256((ROOT / entry['path']).read_bytes()).hexdigest() == entry['sha256'], f'Unresolved-class reviewed source changed: {entry["path"]}')
        installer = item['active_installer']
        require(installer['required_call'] in (ROOT / installer['entry']).read_text(), 'Current bare-installer entry changed')
        require(installer['required_call_in_implementation'] in (ROOT / installer['implementation']).read_text(), 'Current bare-installer implementation changed')
        print(f'WARN unresolved class: {item["class"]}; classification={item["classification"]}; runtime={item["runtime_status"]}')


def class_graph(identity, rules, checks):
    declarations = {}
    owned = (identity['java']['base_package'].replace('.', '/') + '/', identity['application']['id'].replace('.', '/') + '/')
    references = set()
    natives = []
    content_by_path = {}
    for path in APP.glob('smali*/**/*.smali'):
        content = path.read_text()
        content_by_path[path.relative_to(ROOT).as_posix()] = content
        match = re.search(r'^\.class .*?L([^;]+);$', content, re.M)
        require(match is not None, f'Missing class declaration: {path}')
        name = match.group(1)
        require(name not in declarations, f'Duplicate class: {name}')
        declarations[name] = path
        require(path.relative_to(APP).as_posix().split('/', 1)[1] == name + '.smali', f'Class/file mismatch: {path}')
        references.update(value for value in re.findall(r'L([A-Za-z0-9_/$]+);', content) if value.startswith(owned))
        if name.startswith(owned):
            for method in re.findall(r'^\.method .*?\bnative\s+([^\s(]+)\(', content, re.M):
                natives.append((name, method))
    unresolved = references - declarations.keys()
    current_missing_classes(unresolved, content_by_path, checks)
    inherited = rules.get('inherited_missing_classes', []) if rules is not None else []
    if rules is not None:
        require(unresolved == {item['after'] for item in inherited}, 'Local baseline exception differs from current source contract')
    if inherited:
        history = ROOT / identity['history']['root']
        baseline = json.loads((history / '20261118-before-branding/evidence/source-baseline.json').read_text())
        original_declarations = set()
        original_references = set()
        for path in Path(baseline['source']).glob('smali*/**/*.smali'):
            content = path.read_text()
            original_declarations.update(re.findall(r'^\.class .*?L([^;]+);$', content, re.M))
            original_references.update(re.findall(r'L([A-Za-z0-9_/$]+);', content))
        for item in inherited:
            require(item['before'] in original_references and item['before'] not in original_declarations, 'Missing-class baseline exception no longer valid')
        print('INFO inherited unresolved classes: ' + ', '.join(sorted(unresolved)))
    manifest = ET.parse(APP / 'AndroidManifest.xml').getroot()
    for tag in ('application', 'activity', 'service', 'receiver', 'provider'):
        for element in manifest.iter(tag):
            name = element.get(ANDROID + 'name')
            if name and not name.startswith('android.'):
                require(name.replace('.', '/') in declarations, f'Manifest class missing: {name}')
    for path in source_paths():
        if not path.is_file() or path.suffix != '.xml' or APP not in path.parents:
            continue
        for element in ET.parse(path).getroot().iter():
            for value in (element.tag, element.get('class', '')):
                if value.startswith(identity['java']['base_package'] + '.'):
                    require(value.replace('.', '/') in declarations, f'Resource class missing: {value}')
    java_count = 0
    for path in (APP / 'server-java').rglob('*.java'):
        match = re.search(r'^package ([^;]+);', path.read_text(), re.M)
        require(match is not None, f'Java package missing: {path}')
        require(path.parent.relative_to(APP / 'server-java').as_posix() == match.group(1).replace('.', '/'), f'Java package/file mismatch: {path}')
        require(match.group(1).startswith(identity['java']['base_package'] + '.'), f'Unexpected Java namespace: {path}')
        java_count += 1
    print(f'PASS class graph: {len(declarations)} smali declarations, {len(references)} application references, {java_count} Java sources')
    return natives


def exported_symbols(path):
    data = path.read_bytes()
    require(data[:6] in (b'\x7fELF\x01\x01', b'\x7fELF\x02\x01'), f'Unsupported ELF: {path}')
    wide = data[4] == 2
    header = struct.unpack_from('<' + ('HHIQQQIHHHHHH' if wide else 'HHIIIIIHHHHHH'), data, 16)
    offset, size, count = header[5], header[10], header[11]
    section_format = '<' + ('IIQQQQIIQQ' if wide else 'IIIIIIIIII')
    sections = [struct.unpack_from(section_format, data, offset + index * size) for index in range(count)]
    result = set()
    for section in sections:
        if section[1] != 11:
            continue
        strings = sections[section[6]]
        string_data = data[strings[4]:strings[4] + strings[5]]
        for current in range(section[4], section[4] + section[5], section[9]):
            value = struct.unpack_from('<' + ('IBBHQQ' if wide else 'IIIBBH'), data, current)
            index, info, defined = (value[0], value[1], value[3]) if wide else (value[0], value[3], value[5])
            if defined and info >> 4 in (1, 2):
                result.add(string_data[index:string_data.find(b'\0', index)].decode('ascii'))
    return result


def mangle(value):
    return value.replace('_', '_1').replace('/', '_').replace(';', '_2').replace('[', '_3').replace('$', '_00024')


def native_mapping(identity, natives):
    exported = set()
    libraries = 0
    for path in (APP / 'lib/arm64-v8a').glob('*.so'):
        if path.read_bytes()[:4] == b'\x7fELF':
            symbols = exported_symbols(path)
            exported.update(symbols)
            libraries += 1
    expected = {'Java_' + mangle(name) + '_' + mangle(method) for name, method in natives}
    missing = sorted(symbol for symbol in expected if symbol not in exported and not any(value.startswith(symbol + '__') for value in exported))
    require(not missing, f'Native declarations without exports: {missing}')
    pty = APP / ('lib/arm64-v8a/lib' + identity['native']['pty_library'] + '.so')
    display = APP / ('lib/arm64-v8a/lib' + identity['native']['display_library'] + '.so')
    require(pty.is_file() and display.is_file(), 'Renamed native libraries missing')
    c_symbols = set(re.findall(r'\b(Java_\w+)\(', (APP / 'native/pty.c').read_text()))
    pty_symbols = exported_symbols(pty)
    require(c_symbols and c_symbols <= pty_symbols, 'PTY C/JNI export mismatch')
    print(f'PASS JNI mapping: {len(expected)} application native methods, {len(c_symbols)} PTY C exports, {libraries} ELF libraries inspected')


def runtime_parity(identity):
    source = ROOT / identity['paths']['service_source']
    assets = ROOT / identity['paths']['service_assets']
    modules = ('server.py', 'model_runtime.py', 'ingestion.py', 'retrieval.py')
    for module in modules:
        require((source / module).read_bytes() == (assets / module).read_bytes(), f'Service/asset mismatch: {module}')
    java = APP / 'server-java' / identity['java']['runtime_package'].replace('.', '/')
    smali = APP / 'smali_classes2' / identity['java']['runtime_package'].replace('.', '/')
    for name in ('MachineEngine', 'CliProxyProfiles', 'SemanticSettings', 'SemanticRag'):
        get_protocols = lambda value: set(re.findall(r'(?:t-eec|teec)\.[a-zA-Z0-9_.-]+/[0-9]+', value))
        require(get_protocols((java / (name + '.java')).read_text()) == get_protocols((smali / (name + '.smali')).read_text()), f'Java/smali protocol mismatch: {name}')
    runtime = (java / 'UbuntuRuntime.java').read_text()
    terminal = (java / 'TerminalServer.java').read_text()
    ssh = (java / 'UbuntuSsh.java').read_text()
    rag = (java / 'SemanticRag.java').read_text()
    require('http://0.0.0.0:8866/terminal' in runtime and 'new InetSocketAddress("0.0.0.0", port)' in terminal, 'Public terminal binding changed')
    require('int PORT = 8122;' in ssh and 'int PORT = 8867;' in rag, 'Private-copy ports changed')
    require('"--host", "0.0.0.0"' in rag, 'RAG public binding changed')
    require(identity['paths']['guest_frontend'] in (java / 'UbuntuRuntimeService.java').read_text(), 'External frontend path mismatch')
    for path in source_paths():
        if path.is_file() and path.suffix == '.py':
            ast.parse(path.read_text(), filename=str(path))
    xml_count = 0
    for path in source_paths():
        if path.is_file() and path.suffix == '.xml' and APP in path.parents:
            ET.parse(path)
            xml_count += 1
    print(f'PASS Python AST, {xml_count} XML files, service/assets, protocol literals and access settings')


def original_baseline(identity):
    history = ROOT / identity['history']['root']
    baseline = json.loads((history / '20261118-before-branding/evidence/source-baseline.json').read_text())
    source = Path(baseline['source'])
    digest = hashlib.sha256()
    count = size = 0
    active_inodes = {(path.stat().st_dev, path.stat().st_ino) for path in source_paths() if path.is_file()}
    for path in sorted(source.rglob('*')):
        relative = path.relative_to(source)
        if not path.is_file() or set(relative.parts).intersection(baseline['excluded_names']) or path.suffix in baseline['excluded_suffixes']:
            continue
        data = path.read_bytes()
        digest.update(str(relative).encode() + b'\0' + hashlib.sha256(data).digest())
        require((path.stat().st_dev, path.stat().st_ino) not in active_inodes, f'Shared original file inode: {relative}')
        count += 1
        size += len(data)
    require({'sha256': digest.hexdigest(), 'files': count, 'bytes': size} == baseline['tree'], 'Original source baseline changed')
    print(f'PASS original source baseline: {count} unchanged files, separate file inodes')


def main(argv=None):
    parser = argparse.ArgumentParser(description='Check current T-EEC source identities and bundled payloads.')
    parser.add_argument('--portable', action='store_true', help='Check current source without sibling audit history; excludes retired-name scan and original-source baseline.')
    args = parser.parse_args(argv)
    try:
        identity, rules, checks = load_contract(args.portable)
        print('INFO mode: ' + ('portable current-source verification' if args.portable else 'full local audit with external history'))
        if args.portable:
            print('INFO excluded: retired-name scan and original-source baseline/inode comparison; external history is not loaded')
        print('INFO generated outputs excluded: ' + ', '.join(GENERATED_ROOTS) + '; non-asset __pycache__ directories')
        android_identity(identity)
        natives = class_graph(identity, rules, checks)
        runtime_parity(identity)
        scan_names(rules)
        native_mapping(identity, natives)
        if not args.portable:
            original_baseline(identity)
    except (OSError, ValueError, KeyError, ET.ParseError, struct.error, zipfile.BadZipFile, tarfile.TarError, jsonschema.ValidationError) as error:
        print(f'FAIL {error}', file=sys.stderr)
        return 1
    print('INFO static source and bundled-byte checks only; no build, install or application execution')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
