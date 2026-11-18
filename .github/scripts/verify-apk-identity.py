import json
from pathlib import Path
import re
import sys


def verify(identity_path, metadata_path):
    identity = json.loads(Path(identity_path).read_text())['application']
    metadata = Path(metadata_path).read_text()
    package = re.search(r"^package: name='([^']+)' versionCode='([^']+)' versionName='([^']*)'", metadata, re.MULTILINE)
    if package is None:
        raise ValueError('APK package metadata is missing')
    actual = package.groups()
    expected = (identity['id'], str(identity['version_code']), identity['version_name'])
    if actual != expected:
        raise ValueError('APK package metadata does not match identity.json: ' + repr(actual))
    label = re.search(r"^application-label:'([^']*)'$", metadata, re.MULTILINE)
    if label is None or label[1] != identity['label']:
        raise ValueError('APK application label does not match identity.json')
    architectures = re.search(r'^native-code:(.+)$', metadata, re.MULTILINE)
    if architectures is None or re.findall(r"'([^']+)'", architectures[1]) != ['arm64-v8a']:
        raise ValueError('APK must package exactly the arm64-v8a native ABI')
    print(json.dumps({'application_id': actual[0], 'version_code': int(actual[1]), 'version_name': actual[2], 'label': label[1], 'abi': 'arm64-v8a', 'identity_verified': True}))


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: verify-apk-identity.py IDENTITY_JSON APK_METADATA_TXT')
    verify(*sys.argv[1:])
