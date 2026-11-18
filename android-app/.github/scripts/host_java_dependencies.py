import hashlib
import json
import os
from pathlib import Path


def json_jar(root):
    directory = Path(root) / 'tests/dependencies/org-json-20240303'
    identity = json.loads((directory / 'identity.json').read_text(encoding='utf-8'))
    if identity.get('coordinate') != 'org.json:json:20240303' or identity.get('scope') != 'host-tests-only':
        raise RuntimeError('Unexpected host JSON dependency identity')
    for name in ('json-20240303.jar', 'LICENSE'):
        path = directory / name
        value = path.read_bytes()
        expected = identity['files'][name]
        if len(value) != expected['bytes'] or hashlib.sha256(value).hexdigest() != expected['sha256']:
            raise RuntimeError('Host JSON dependency integrity check failed: ' + str(path))
    return directory / 'json-20240303.jar'


def json_classpath(root, *entries):
    return os.pathsep.join(str(entry) for entry in (*entries, json_jar(root)))
