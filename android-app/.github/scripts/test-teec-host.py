import argparse
import hashlib
import json
import os
from pathlib import Path
import select
import shlex
import shutil
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import time


def counted(data):
    return format(len(data), '04x').encode('ascii') + data


def frame(channel, data):
    return struct.pack('<BI', channel, len(data)) + data


def exact(connection, length):
    value = bytearray()
    while len(value) < length:
        chunk = connection.recv(length - len(value))
        if not chunk:
            raise AssertionError('Client disconnected before completing its protocol request')
        value.extend(chunk)
    return bytes(value)


class SyntheticAdb:
    def __init__(self, case, argv):
        self.case = case
        self.argv = argv
        self.listener = socket.socket()
        self.listener.bind(('127.0.0.1', 0))
        self.listener.listen()
        self.listener.settimeout(.05)
        self.port = self.listener.getsockname()[1]
        assert self.port != 5037
        self.stopped = threading.Event()
        self.release = threading.Event()
        self.connections = 0
        self.requests = []
        self.errors = []
        self.stdin_closed = False
        self.thread = threading.Thread(target=self.serve, daemon=True)
        self.thread.start()

    def send(self, connection, data):
        if self.case.get('fragmented'):
            for byte in data:
                connection.sendall(bytes([byte]))
                time.sleep(.001)
        else:
            connection.sendall(data)

    def request(self, connection):
        size = exact(connection, 4)
        assert all(byte in b'0123456789abcdefABCDEF' for byte in size), size
        value = exact(connection, int(size, 16)).decode('utf-8', 'surrogateescape')
        self.requests.append(value)
        return value

    def serve(self):
        while not self.stopped.is_set():
            try:
                connection, _ = self.listener.accept()
            except socket.timeout:
                continue
            except OSError:
                return
            self.connections += 1
            try:
                with connection:
                    connection.settimeout(5)
                    if self.connections == 1:
                        assert self.request(connection) == 'host:devices-l'
                        devices = self.case.get('devices', b'test-phone\tdevice product:test model:Mock_Device device:mock transport_id:7\n')
                        self.send(connection, self.case.get('discovery', b'OKAY' + counted(devices)))
                    elif self.connections == 2:
                        assert self.request(connection) == 'host:transport:' + self.case.get('selected', 'test-phone')
                        self.send(connection, self.case.get('transport', b'OKAY'))
                        if self.case.get('transport', b'OKAY') != b'OKAY':
                            continue
                        executable = shlex.quote(self.argv[0])
                        if not executable.startswith("'"):
                            executable = "'" + executable + "'"
                        command = executable + ((' ' + shlex.join(self.argv[1:])) if len(self.argv) > 1 else '')
                        service = self.request(connection)
                        assert service == 'shell,v2,raw:' + command, service
                        assert shlex.split(service[len('shell,v2,raw:'):]) == self.argv
                        self.send(connection, self.case.get('shell', b'OKAY'))
                        if self.case.get('shell', b'OKAY') != b'OKAY':
                            continue
                        assert exact(connection, 5) == struct.pack('<BI', 4, 0)
                        self.stdin_closed = True
                        self.send(connection, self.case.get('frames', frame(1, b'hello\n') + frame(3, b'\0')))
                        if self.case.get('streaming'):
                            assert self.release.wait(5), 'Output was not streamed before process completion'
                            self.send(connection, frame(3, b'\0'))
                    else:
                        raise AssertionError('Client retried or opened an unexpected ADB connection')
            except Exception as failure:
                self.errors.append(repr(failure))

    def close(self):
        self.release.set()
        self.stopped.set()
        self.listener.close()
        self.thread.join(timeout=6)
        assert not self.thread.is_alive(), 'Synthetic ADB thread did not stop'


LAUNCHER = '''import json
import runpy
import socket
import sys
sys.dont_write_bytecode = True
target, port, arguments = sys.argv[1:]
original = socket.create_connection
def connect(address, *args, **kwargs):
    sys.stderr.write('TEST_TARGET=' + json.dumps(address) + '\\n')
    return original(('127.0.0.1', int(port)), *args, **kwargs)
socket.create_connection = connect
sys.argv = [target, *json.loads(arguments)]
runpy.run_path(target, run_name='__main__')
'''


def run_case(client, case):
    argv = case.get('argv', ['echo', 'hello'])
    server = SyntheticAdb(case, argv)
    environment = dict(os.environ)
    for name in ('TEEC_ADB_HOST', 'TEEC_ADB_PORT', 'ANDROID_SERIAL', 'ADB_SERVER_SOCKET'):
        environment.pop(name, None)
    environment['PYTHONDONTWRITEBYTECODE'] = '1'
    environment.update(case.get('environment', {}))
    options = [] if case.get('plain') else ['--json']
    if case.get('defaults'):
        pass
    elif case.get('environment_endpoint'):
        environment.update(TEEC_ADB_HOST='127.0.0.1', TEEC_ADB_PORT=str(server.port))
    else:
        options.extend(['--host', '127.0.0.1', '--port', str(server.port)])
    options.extend(case.get('options', []))
    options.extend(['--', *argv])
    if case.get('launcher') or case.get('defaults'):
        command = [sys.executable, '-c', LAUNCHER, str(client), str(server.port), json.dumps(options)]
    else:
        command = [sys.executable, str(client), *options]
    process = None
    early = {1: bytearray(), 2: bytearray()}
    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=environment)
        if case.get('streaming'):
            deadline = time.monotonic() + 4
            while b'early-out' not in early[1] or b'early-err' not in early[2]:
                remaining = deadline - time.monotonic()
                assert remaining > 0, 'Plain output waited for remote exit'
                ready, _, _ = select.select([process.stdout, process.stderr], [], [], remaining)
                for stream in ready:
                    data = os.read(stream.fileno(), 4096)
                    assert data, 'Client exited before streaming both channels'
                    early[1 if stream is process.stdout else 2].extend(data)
            assert process.poll() is None, 'Remote exit was not gated during streaming check'
            server.release.set()
        stdout, stderr = process.communicate(timeout=10)
        stdout = bytes(early[1]) + stdout
        stderr = bytes(early[2]) + stderr
    finally:
        server.release.set()
        if process is not None and process.poll() is None:
            process.kill()
            process.communicate()
        server.close()
    assert not server.errors, server.errors
    assert server.connections == case.get('connections', 2), (server.connections, server.requests)
    if case.get('connections', 2) == 2 and 'transport' not in case and 'shell' not in case:
        assert server.stdin_closed, 'Client did not send shell-v2 close_stdin'
    expected_exit = case.get('exit', 0)
    failed = case.get('failure', False)
    assert process.returncode == (1 if failed else expected_exit), (process.returncode, stdout, stderr)
    if case.get('plain'):
        assert stdout == case.get('stdout', b'hello\n'), stdout
        if failed:
            assert stderr.startswith(case.get('stderr', b'')), stderr
            assert b'teec-host:' in stderr, stderr
        else:
            assert stderr == case.get('stderr', b''), stderr
    else:
        assert stdout.isascii(), 'JSON transport must escape non-ASCII code units'
        data = json.loads(stdout)
        assert data['schema'] == 'teec.host-command/1', data
        target = ['127.0.0.1', 5037] if case.get('defaults') else ['127.0.0.1', server.port]
        assert data['provider'] == {'kind': 'adb-shell-v2', 'host': target[0], 'port': target[1]}, data
        assert data['argv'] == argv, data
        assert data['stdout'].encode('utf-8', 'surrogateescape') == case.get('stdout', b'hello\n'), data
        assert data['stderr'].encode('utf-8', 'surrogateescape') == case.get('stderr', b''), data
        assert data['stdout_bytes'] == len(case.get('stdout', b'hello\n')), data
        assert data['stderr_bytes'] == len(case.get('stderr', b'')), data
        assert data['exit'] == (None if failed else expected_exit), data
        if failed:
            assert isinstance(data['error'], str) and data['error'], data
        else:
            assert data['error'] is None, data
            assert data['device']['serial'] == case.get('selected', 'test-phone'), data
            assert data['device']['state'] == 'device', data
            listed = case.get('devices', b'test-phone\tdevice product:test model:Mock_Device device:mock transport_id:7\n').decode().splitlines()
            selected = next(line.split(None, 2) for line in listed if line.split(None, 1)[0] == data['device']['serial'])
            assert data['device']['details'] == (selected[2] if len(selected) > 2 else ''), data
        if case.get('defaults'):
            targets = [json.loads(line.split(b'=', 1)[1]) for line in stderr.splitlines()]
            assert targets == [target, target], targets
        else:
            assert stderr == b'', stderr
    return {'name': case['name'], 'passed': True, 'connections': server.connections, 'requests': server.requests}


def cases():
    binary = b'\0\xff\xfe\x80' + 'Türkçe ✓\n'.encode()
    devices = b'alpha\tdevice model:Alpha transport_id:1\nbeta\tdevice model:Beta transport_id:2\n'
    partial = frame(1, b'kept-out') + frame(2, b'kept-err')
    result = [
        {'name': 'fragmented_lossless_json', 'fragmented': True, 'frames': frame(1, binary) + frame(2, b'\xfferr\n') + frame(3, b'\0'), 'stdout': binary, 'stderr': b'\xfferr\n'},
        {'name': 'plain_binary_bytes', 'plain': True, 'frames': frame(1, binary) + frame(2, b'\xfferr\n') + frame(3, b'\0'), 'stdout': binary, 'stderr': b'\xfferr\n'},
        {'name': 'json_nonzero_exit', 'frames': frame(1, b'failed-out') + frame(3, b'\x17'), 'stdout': b'failed-out', 'exit': 23},
        {'name': 'plain_nonzero_exit', 'plain': True, 'frames': frame(2, b'failure') + frame(3, b'\xff'), 'stdout': b'', 'stderr': b'failure', 'exit': 255},
        {'name': 'stderr_with_success', 'frames': frame(2, b'warning') + frame(3, b'\0'), 'stdout': b'', 'stderr': b'warning'},
        {'name': 'zero_length_output_frames', 'frames': frame(1, b'') + frame(2, b'') + frame(3, b'\0'), 'stdout': b''},
        {'name': 'literal_argv_quoting', 'argv': ['/system/bin/printf', '%s', '', "quote ' and \"", '$(literal); | & > <', 'line\nbreak', 'Türkçe ✓', '--json']},
        {'name': 'reserved_word_executable', 'argv': ['if', 'space value', '', 'Türkçe ✓']},
        {'name': 'assignment_like_executable', 'argv': ['X=value', 'space value', '', 'Türkçe ✓']},
        {'name': 'quote_in_executable', 'argv': ["odd'name", 'space value', '', 'Türkçe ✓']},
        {'name': 'plain_immediate_streaming', 'plain': True, 'streaming': True, 'frames': frame(1, b'early-out') + frame(2, b'early-err'), 'stdout': b'early-out', 'stderr': b'early-err'},
        {'name': 'partial_output_no_exit', 'frames': partial, 'failure': True, 'stdout': b'kept-out', 'stderr': b'kept-err'},
        {'name': 'partial_frame_output_preserved', 'frames': partial + struct.pack('<BI', 1, 9) + b'part', 'failure': True, 'stdout': b'kept-outpart', 'stderr': b'kept-err'},
        {'name': 'plain_partial_failure_diagnostic', 'plain': True, 'frames': partial, 'failure': True, 'stdout': b'kept-out', 'stderr': b'kept-err'},
        {'name': 'multiple_devices_need_serial', 'devices': devices, 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'explicit_serial', 'devices': devices, 'options': ['--serial', 'beta'], 'selected': 'beta'},
        {'name': 'environment_serial', 'devices': devices, 'environment': {'ANDROID_SERIAL': 'alpha'}, 'selected': 'alpha'},
        {'name': 'cli_overrides_environment', 'devices': devices, 'environment': {'ANDROID_SERIAL': 'alpha', 'TEEC_ADB_HOST': '127.0.0.2', 'TEEC_ADB_PORT': '1'}, 'options': ['--serial', 'beta'], 'selected': 'beta'},
        {'name': 'environment_endpoint', 'environment_endpoint': True},
        {'name': 'default_endpoint_without_live_connection', 'defaults': True},
        {'name': 'ignore_offline_when_one_connected', 'devices': b'offline-phone\toffline\ntest-phone\tdevice model:Mock_Device\n'},
        {'name': 'no_devices', 'devices': b'', 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'unauthorized_device', 'devices': b'test-phone\tunauthorized\n', 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'requested_offline_device', 'devices': b'test-phone\toffline\n', 'options': ['--serial', 'test-phone'], 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'unknown_serial', 'options': ['--serial', 'absent'], 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'discovery_fail', 'discovery': b'FAIL' + counted(b'synthetic discovery failure'), 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'transport_fail', 'transport': b'FAIL' + counted(b'synthetic transport failure'), 'failure': True, 'stdout': b''},
        {'name': 'shell_fail', 'shell': b'FAIL' + counted(b'synthetic shell failure'), 'failure': True, 'stdout': b''},
        {'name': 'malformed_discovery_length', 'discovery': b'OKAYzzzz', 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'truncated_discovery_payload', 'discovery': b'OKAY0009abc', 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'malformed_status', 'discovery': b'NOPE', 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'malformed_fail_length', 'discovery': b'FAILzzzz', 'failure': True, 'connections': 1, 'stdout': b''},
        {'name': 'nul_argument_rejected_before_connect', 'launcher': True, 'argv': ['echo', 'before\0after'], 'failure': True, 'connections': 0, 'stdout': b''},
        {'name': 'empty_executable_rejected_before_connect', 'argv': ['', 'argument'], 'failure': True, 'connections': 0, 'stdout': b''},
    ]
    for name, suffix in [('invalid_channel', frame(9, b'x')), ('empty_exit', frame(3, b'')), ('oversized_exit', frame(3, b'\0\0')), ('truncated_exit', struct.pack('<BI', 3, 1)), ('truncated_header', b'\x01\x01\0')]:
        result.append({'name': name, 'frames': partial + suffix, 'failure': True, 'stdout': b'kept-out', 'stderr': b'kept-err'})
    return result


def shell_proof(results, directory):
    shell = shutil.which('sh')
    assert shell, 'A POSIX shell is required for literal executable checks'
    tested = []
    with tempfile.TemporaryDirectory(prefix='teec-host-shell-', dir=directory) as temporary:
        work = Path(temporary)
        for case_name, filename in [('reserved_word_executable', 'if'), ('assignment_like_executable', 'X=value'), ('quote_in_executable', "odd'name")]:
            case = next(item for item in results if item['name'] == case_name)
            assert case['passed'], case
            fixture = work / filename
            fixture.write_text("printf '%s\\000' \"$0\" \"$@\"\n")
            fixture.chmod(0o700)
            command = case['requests'][-1][len('shell,v2,raw:'):]
            result = subprocess.run([shell, '-c', command], env=dict(os.environ, PATH=str(work)), capture_output=True, timeout=5)
            assert result.returncode == 0 and result.stderr == b'', result
            values = result.stdout.split(b'\0')
            assert Path(os.fsdecode(values[0])).name == filename, values
            assert values[1:] == [b'space value', b'', 'Türkçe ✓'.encode(), b''], values
            tested.append(filename)
    return {'name': 'posix_shell_literal_executable_execution', 'passed': True, 'executables': tested, 'scratch_removed': not work.exists()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--client', type=Path, default=Path(__file__).resolve().parents[2] / 'tools/teec-host.py')
    parser.add_argument('--evidence', type=Path)
    options = parser.parse_args()
    if options.evidence:
        options.evidence.parent.mkdir(parents=True, exist_ok=True)
    results = []
    for case in cases():
        try:
            results.append(run_case(options.client, case))
        except Exception as failure:
            results.append({'name': case['name'], 'passed': False, 'error': repr(failure)})
    try:
        results.append(shell_proof(results, options.evidence.parent if options.evidence else None))
    except Exception as failure:
        results.append({'name': 'posix_shell_literal_executable_execution', 'passed': False, 'error': repr(failure)})
    result = {'schema': 'teec.host-client-tests/1', 'passed': all(item['passed'] for item in results), 'tests': len(results), 'results': results,
              'client_sha256': hashlib.sha256(options.client.read_bytes()).hexdigest(), 'test_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'live_adb_contacted': False, 'adb_server_started': False, 'apk_built': False, 'app_installed': False}
    if options.evidence:
        options.evidence.parent.mkdir(parents=True, exist_ok=True)
        options.evidence.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    sys.exit(main())
