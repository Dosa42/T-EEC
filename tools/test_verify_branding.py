import contextlib
import hashlib
import importlib.util
import io
import json
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location('verify_branding', Path(__file__).with_name('verify-branding.py'))
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)
SOURCE = CHECKER.ROOT


class PortableChecksTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='teec-check-')
        self.root = Path(self.temporary.name)
        self.root_patch = patch.object(CHECKER, 'ROOT', self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)
        self.addCleanup(self.temporary.cleanup)
        self.output = contextlib.redirect_stdout(io.StringIO())
        self.output.__enter__()
        self.addCleanup(self.output.__exit__, None, None, None)

    def write(self, name, value):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)
        return path

    def fixture_contract(self):
        for name in ('identity.json', 'tools/identity.schema.json', 'tools/current-source-checks.schema.json'):
            self.write(name, (SOURCE / name).read_text())
        self.write('tools/current-source-checks.json', json.dumps({'schema': 'teec.source-checks/1', 'unresolved_owned_classes': []}))

    def orphan_fixture(self):
        name = 'teec/shell/term_shell/Applications/Linux/DeployLinuxImage'
        content = 'check-cast v0, L' + name + ';\n'
        referrer = self.write('android-app/smali_classes2/fixture/Caller.smali', content)
        self.write('android-app/Entry.smali', 'call UbuntuRootfs.ensureInstalled')
        self.write('android-app/Installer.java', 'UbuntuImage.install(archive)')
        entry = {'class': name, 'classification': 'inherited_orphan_installer_branch', 'runtime_status': 'not_verified',
                 'referrers': [{'path': referrer.relative_to(self.root).as_posix(),
                                'references': 1, 'sha256': hashlib.sha256(content.encode()).hexdigest()}],
                 'active_installer': {'entry': 'android-app/Entry.smali', 'required_call': 'UbuntuRootfs.ensureInstalled',
                                      'implementation': 'android-app/Installer.java', 'required_call_in_implementation': 'UbuntuImage.install('}}
        return name, {referrer.relative_to(self.root).as_posix(): content}, {'unresolved_owned_classes': [entry]}

    def test_portable_load_does_not_require_external_history(self):
        self.fixture_contract()
        identity, rules, checks = CHECKER.load_contract(portable=True)
        self.assertEqual(identity['application']['id'], 'io.teec')
        self.assertIsNone(rules)
        self.assertEqual(checks['unresolved_owned_classes'], [])

    def test_local_audit_fails_if_external_history_missing(self):
        self.fixture_contract()
        with self.assertRaises(FileNotFoundError):
            CHECKER.load_contract()

    def test_invalid_current_contract_fails(self):
        self.fixture_contract()
        self.write('tools/current-source-checks.json', json.dumps({'schema': 'teec.source-checks/1', 'unresolved_owned_classes': [], 'allow_everything': True}))
        with self.assertRaises(CHECKER.jsonschema.ValidationError):
            CHECKER.load_contract(portable=True)

    def test_generated_roots_excluded_without_excluding_asset_names(self):
        for name in ('.git/config', 'build/result', 'android-app/dist/result', 'android-app/build/result',
                     'tools/__pycache__/x.pyc', 'android-app/assets/build/keep', 'android-app/assets/__pycache__/keep'):
            self.write(name, 'content')
        actual = {path.relative_to(self.root).as_posix() for path in CHECKER.source_paths() if path.is_file()}
        self.assertEqual(actual, {'android-app/assets/build/keep', 'android-app/assets/__pycache__/keep'})

    def test_portable_checks_archive_readability(self):
        self.write('payload.zip', 'invalid zip')
        with self.assertRaises(zipfile.BadZipFile):
            CHECKER.scan_names()

    def test_local_patterns_scan_decoded_archive_content(self):
        with zipfile.ZipFile(self.root / 'payload.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
            archive.writestr('content.txt', 'retiredbrand')
        rules = {'patterns': [{'id': 'retired', 'pattern': 'retiredbrand'}]}
        with self.assertRaisesRegex(ValueError, 'member content'):
            CHECKER.scan_names(rules)

    def test_source_symlink_rejected(self):
        self.write('file', 'content')
        (self.root / 'linked').symlink_to(self.root / 'file')
        with self.assertRaisesRegex(ValueError, 'shared symlink'):
            CHECKER.scan_names()

    def test_reviewed_orphan_is_explicitly_accepted(self):
        name, contents, checks = self.orphan_fixture()
        CHECKER.current_missing_classes({name}, contents, checks)

    def test_new_missing_class_is_rejected(self):
        name, contents, checks = self.orphan_fixture()
        with self.assertRaisesRegex(ValueError, 'Unexpected unresolved'):
            CHECKER.current_missing_classes({name, 'teec/shell/Other'}, contents, checks)

    def test_missing_exception_must_be_removed_when_class_is_supplied(self):
        name, contents, checks = self.orphan_fixture()
        with self.assertRaisesRegex(ValueError, 'Unexpected unresolved'):
            CHECKER.current_missing_classes(set(), contents, checks)

    def test_new_orphan_referrer_rejected(self):
        name, contents, checks = self.orphan_fixture()
        contents['android-app/smali/Extra.smali'] = 'L' + name + ';'
        with self.assertRaisesRegex(ValueError, 'referrer scope'):
            CHECKER.current_missing_classes({name}, contents, checks)

    def test_changed_reviewed_branch_rejected(self):
        name, contents, checks = self.orphan_fixture()
        path = next(iter(contents))
        contents[path] += 'return-void\n'
        self.write(path, contents[path])
        with self.assertRaisesRegex(ValueError, 'reviewed source changed'):
            CHECKER.current_missing_classes({name}, contents, checks)

    def test_bare_installer_entry_is_required(self):
        name, contents, checks = self.orphan_fixture()
        self.write('android-app/Entry.smali', 'absent')
        with self.assertRaisesRegex(ValueError, 'bare-installer entry'):
            CHECKER.current_missing_classes({name}, contents, checks)


if __name__ == '__main__':
    unittest.main()
