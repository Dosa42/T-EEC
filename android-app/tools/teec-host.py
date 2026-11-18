import argparse
import json
import os
import shlex
import socket
import struct
import sys


class AdbError(Exception):
    pass


def receive_exact(connection, length, context):
    result = bytearray()
    while len(result) < length:
        chunk = connection.recv(length - len(result))
        if not chunk:
            raise AdbError('ADB disconnected during ' + context)
        result.extend(chunk)
    return bytes(result)


def receive_string(connection, context):
    size = receive_exact(connection, 4, context + ' length')
    if any(value not in b'0123456789abcdefABCDEF' for value in size):
        raise AdbError('Malformed ADB hexadecimal length during ' + context)
    return receive_exact(connection, int(size, 16), context)


def request(connection, service):
    data = service.encode('utf-8', 'surrogateescape')
    if not data or len(data) > 65535 or b'\0' in data:
        raise AdbError('ADB service request must fit its four-digit length field and contain no NUL')
    connection.sendall(format(len(data), '04x').encode('ascii') + data)
    status = receive_exact(connection, 4, 'service status')
    if status == b'FAIL':
        reason = receive_string(connection, 'failure reason').decode('utf-8', 'surrogateescape')
        raise AdbError('ADB rejected request: ' + reason)
    if status != b'OKAY':
        raise AdbError('Malformed ADB status: ' + repr(status))


def devices(host, port):
    with socket.create_connection((host, port)) as connection:
        request(connection, 'host:devices-l')
        text = receive_string(connection, 'device list').decode('utf-8', 'strict')
    result = []
    seen = set()
    for line in text.splitlines():
        if not line:
            continue
        fields = line.split(None, 2)
        if len(fields) < 2 or '\0' in line or fields[0] in seen:
            raise AdbError('Malformed ADB device list')
        seen.add(fields[0])
        result.append({'serial': fields[0], 'state': fields[1], 'details': fields[2] if len(fields) > 2 else ''})
    return result


def select_device(available, serial):
    if serial is not None:
        matches = [device for device in available if device['serial'] == serial]
        if not matches:
            raise AdbError('Requested ADB device is not listed: ' + serial)
        if matches[0]['state'] != 'device':
            raise AdbError('Requested ADB device is ' + matches[0]['state'] + ': ' + serial)
        return matches[0]
    connected = [device for device in available if device['state'] == 'device']
    if len(connected) > 1:
        raise AdbError('Multiple connected ADB devices; select --serial or ANDROID_SERIAL: ' + ', '.join(device['serial'] for device in connected))
    if not connected:
        states = ', '.join(device['serial'] + '=' + device['state'] for device in available)
        raise AdbError('No connected ADB device' + (': ' + states if states else ''))
    return connected[0]


def shell(host, port, serial, argv, output):
    if not argv or not argv[0] or any('\0' in item for item in argv):
        raise AdbError('A nonempty executable and NUL-free arguments are required')
    command = "'" + argv[0].replace("'", "'\"'\"'") + "'"
    command += ''.join(' ' + shlex.quote(argument) for argument in argv[1:])
    with socket.create_connection((host, port)) as connection:
        request(connection, 'host:transport:' + serial)
        request(connection, 'shell,v2,raw:' + command)
        connection.sendall(struct.pack('<BI', 4, 0))
        while True:
            channel, length = struct.unpack('<BI', receive_exact(connection, 5, 'shell frame header before exit'))
            if channel == 3:
                if length != 1:
                    raise AdbError('Malformed ADB exit frame length: ' + str(length))
                return receive_exact(connection, 1, 'shell exit code')[0]
            if channel not in (1, 2):
                raise AdbError('Unexpected ADB shell channel: ' + str(channel))
            while length:
                data = connection.recv(min(length, 65536))
                if not data:
                    raise AdbError('ADB disconnected during shell output before exit')
                output(channel, data)
                length -= len(data)


def main(argv=None):
    parser = argparse.ArgumentParser(prog='teec-host', description='Run exact command arguments through the existing paired ADB server.')
    parser.add_argument('--json', action='store_true', help='Return stdout, stderr, exit and provider/device metadata as JSON.')
    parser.add_argument('--serial', default=os.environ.get('ANDROID_SERIAL') or None)
    parser.add_argument('--host', default=os.environ.get('TEEC_ADB_HOST', '127.0.0.1'))
    parser.add_argument('--port', type=int, default=os.environ.get('TEEC_ADB_PORT', '5037'))
    parser.add_argument('command', nargs=argparse.REMAINDER)
    options = parser.parse_args(argv)
    command = options.command[1:] if options.command[:1] == ['--'] else options.command
    if not command:
        parser.error('a command is required; interactive stdin is not supported')
    result = {'schema': 'teec.host-command/1', 'provider': {'kind': 'adb-shell-v2', 'host': options.host, 'port': options.port}, 'device': None, 'argv': command, 'stdout': '', 'stderr': '', 'stdout_bytes': 0, 'stderr_bytes': 0, 'exit': None, 'error': None}
    captured = {1: bytearray(), 2: bytearray()}

    def output(channel, data):
        name = 'stdout' if channel == 1 else 'stderr'
        result[name + '_bytes'] += len(data)
        if options.json:
            captured[channel].extend(data)
        else:
            target = sys.stdout.buffer if channel == 1 else sys.stderr.buffer
            target.write(data)
            target.flush()

    try:
        if not 1 <= options.port <= 65535:
            raise AdbError('ADB server port must be between 1 and 65535')
        if not command[0] or any('\0' in item for item in command):
            raise AdbError('A nonempty executable and NUL-free arguments are required')
        result['device'] = select_device(devices(options.host, options.port), options.serial)
        result['exit'] = shell(options.host, options.port, result['device']['serial'], command, output)
    except (AdbError, OSError, UnicodeError, ValueError) as error:
        result['error'] = str(error)
    if options.json:
        result['stdout'] = bytes(captured[1]).decode('utf-8', 'surrogateescape')
        result['stderr'] = bytes(captured[2]).decode('utf-8', 'surrogateescape')
        print(json.dumps(result, ensure_ascii=True))
    elif result['error'] is not None:
        print('teec-host: ' + result['error'], file=sys.stderr)
    return result['exit'] if result['error'] is None else 1


if __name__ == '__main__':
    sys.exit(main())
