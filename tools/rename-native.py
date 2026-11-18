import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import tempfile


def digest(data):
    return hashlib.sha256(data).hexdigest()


def replace(data, pairs):
    for old, new in pairs:
        data = data.replace(old, new)
    return data


class Elf:
    def __init__(self, data):
        if data[:6] != b'\x7fELF\x02\x01':
            raise ValueError('Only ELF64 little-endian inputs are supported')
        self.data = data
        header = struct.unpack_from('<16sHHIQQQIHHHHHH', data)
        self.machine = header[2]
        self.entry = header[4]
        shoff, shsize, shnum, shnames = header[6], header[11], header[12], header[13]
        raw = [struct.unpack_from('<IIQQQQIIQQ', data, shoff + i * shsize) for i in range(shnum)]
        strings = raw[shnames]
        self.sections = []
        for s in raw:
            start = strings[4] + s[0]
            name = data[start:data.index(b'\0', start)].decode()
            self.sections.append(dict(zip(('name_index', 'type', 'flags', 'address', 'offset', 'size', 'link', 'info', 'align', 'entry_size'), s), name=name))
        self.named = {s['name']: s for s in self.sections}
        self.programs = [struct.unpack_from('<IIQQQQQQ', data, header[5] + i * header[9]) for i in range(header[10])]
        self.symbols = self.read_symbols('.dynsym')
        self.dynamic = self.read_dynamic()

    def bytes(self, section):
        return self.data[section['offset']:section['offset'] + section['size']]

    def string(self, section, offset):
        start = section['offset'] + offset
        if offset < 0 or offset >= section['size']:
            raise ValueError('String-table offset is out of bounds')
        return self.data[start:self.data.index(b'\0', start, section['offset'] + section['size'])]

    def read_symbols(self, name):
        section = self.named.get(name)
        if section is None:
            return []
        strings = self.sections[section['link']]
        versions = self.named.get('.gnu.version') if name == '.dynsym' else None
        result = []
        for i, offset in enumerate(range(section['offset'], section['offset'] + section['size'], section['entry_size'])):
            name_offset, info, other, index, value, size = struct.unpack_from('<IBBHQQ', self.data, offset)
            version = struct.unpack_from('<H', self.data, versions['offset'] + i * 2)[0] if versions else None
            section_name = self.sections[index]['name'] if 0 < index < len(self.sections) else str(index)
            result.append({'name': self.string(strings, name_offset), 'info': info, 'other': other, 'section': section_name, 'index': index, 'value': value, 'size': size, 'version': version})
        return result

    def read_dynamic(self):
        section = self.named.get('.dynamic')
        if section is None:
            return []
        strings = self.sections[section['link']]
        result = []
        for offset in range(section['offset'], section['offset'] + section['size'], 16):
            tag, value = struct.unpack_from('<qQ', self.data, offset)
            if tag == 0:
                break
            if tag in (1, 14, 15, 29):
                result.append((tag, self.string(strings, value)))
        return result

    def relocations(self):
        result = []
        for section in self.sections:
            if section['type'] not in (4, 9) or self.sections[section['link']]['name'] != '.dynsym':
                continue
            for offset in range(section['offset'], section['offset'] + section['size'], section['entry_size']):
                target, info = struct.unpack_from('<QQ', self.data, offset)
                addend = struct.unpack_from('<q', self.data, offset + 16)[0] if section['type'] == 4 else None
                result.append((section['name'], target, info & 0xffffffff, self.symbols[info >> 32]['name'], addend))
        return result

    def verify_hashes(self):
        checked = 0
        section = self.named.get('.gnu.hash')
        if section:
            data = self.bytes(section)
            buckets, first, words, shift = struct.unpack_from('<IIII', data)
            if not buckets or not words:
                raise ValueError('Invalid GNU hash header')
            bloom = struct.unpack_from('<' + 'Q' * words, data, 16)
            table = struct.unpack_from('<' + 'I' * buckets, data, 16 + words * 8)
            chains = 16 + words * 8 + buckets * 4
            for index, symbol in enumerate(self.symbols[first:], first):
                if symbol['index'] == 0 or symbol['info'] >> 4 == 0 or not symbol['name']:
                    continue
                value = 5381
                for byte in symbol['name']:
                    value = (value * 33 + byte) & 0xffffffff
                mask = (1 << (value % 64)) | (1 << ((value >> shift) % 64))
                if bloom[(value // 64) % words] & mask != mask:
                    raise ValueError('GNU bloom misses symbol: ' + symbol['name'].decode())
                item = table[value % buckets]
                found = False
                while first <= item < len(self.symbols):
                    chain = struct.unpack_from('<I', data, chains + (item - first) * 4)[0]
                    if item == index and chain | 1 == value | 1:
                        found = True
                        break
                    if chain & 1:
                        break
                    item += 1
                if not found:
                    raise ValueError('GNU hash misses symbol: ' + symbol['name'].decode())
                checked += 1
        section = self.named.get('.hash')
        if section:
            data = self.bytes(section)
            buckets, count = struct.unpack_from('<II', data)
            table = struct.unpack_from('<' + 'I' * buckets, data, 8)
            chain = struct.unpack_from('<' + 'I' * count, data, 8 + buckets * 4)
            for index, symbol in enumerate(self.symbols[1:], 1):
                if symbol['index'] == 0 or symbol['info'] >> 4 == 0:
                    continue
                value = 0
                for byte in symbol['name']:
                    value = (value << 4) + byte
                    high = value & 0xf0000000
                    if high:
                        value ^= high >> 24
                    value &= ~high
                item, seen = table[value % buckets], set()
                while item and item != index and item not in seen:
                    seen.add(item)
                    item = chain[item]
                if item != index:
                    raise ValueError('SysV hash misses symbol: ' + symbol['name'].decode())
                checked += 1
        for section_name, tag in (('.dynstr', 5), ('.dynsym', 6), ('.gnu.hash', 0x6ffffef5), ('.hash', 4)):
            section = self.named.get(section_name)
            dynamic = self.named.get('.dynamic')
            if section and dynamic:
                tags = dict(struct.unpack_from('<qQ', self.data, offset) for offset in range(dynamic['offset'], dynamic['offset'] + dynamic['size'], 16))
                if tags.get(tag) != section['address']:
                    raise ValueError('Dynamic pointer disagrees with section: ' + section_name)
                if not any(p[0] == 1 and p[3] <= section['address'] and section['address'] + section['size'] <= p[3] + p[5] and section['offset'] - p[2] == section['address'] - p[3] for p in self.programs):
                    raise ValueError('Dynamic section is not mapped: ' + section_name)
        return checked


def compare(before, after, pairs):
    if (before.machine, before.entry) != (after.machine, after.entry):
        raise ValueError('ELF machine or entry point changed')
    page_size = max(p[7] for p in before.programs if p[0] == 1)
    for segment in after.programs:
        if segment[0] == 1 and (segment[2] % segment[7] != segment[3] % segment[7] or segment[2] % page_size != segment[3] % page_size):
            raise ValueError('Load segment lost original page alignment')
    for name, section in before.named.items():
        if section['flags'] & 4:
            changed = after.named.get(name)
            if not changed or section['address'] != changed['address'] or before.bytes(section) != after.bytes(changed):
                raise ValueError('Executable section changed: ' + name)
    def symbol_records(elf, rename):
        return Counter((replace(s['name'], pairs) if rename else s['name'], s['info'], s['other'], s['section'], s['value'], s['size'], s['version']) for s in elf.symbols)
    if symbol_records(before, True) != symbol_records(after, False):
        raise ValueError('Symbol identity/address/version changed unexpectedly')
    expected = Counter((name, target, kind, replace(symbol, pairs), addend) for name, target, kind, symbol, addend in before.relocations())
    if expected != Counter(after.relocations()):
        raise ValueError('Relocation identity changed unexpectedly')
    if [(tag, replace(name, pairs)) for tag, name in before.dynamic] != after.dynamic:
        raise ValueError('Dynamic library/path identity changed unexpectedly')
    return after.verify_hashes()


def load_mapping(path):
    data = json.loads(path.read_text())
    required = {'schema_version', 'targets', 'binary_pairs', 'text_pairs', 'filename_pairs', 'forbidden'}
    if not isinstance(data, dict) or set(data) != required or data['schema_version'] != 1:
        raise ValueError('Invalid mapping schema')
    for key in ('targets', 'forbidden'):
        if not isinstance(data[key], list) or not all(isinstance(s, str) and s for s in data[key]):
            raise ValueError('Invalid string list: ' + key)
    for key in ('binary_pairs', 'text_pairs', 'filename_pairs'):
        if not isinstance(data[key], list):
            raise ValueError('Invalid replacement list: ' + key)
        for pair in data[key]:
            if not isinstance(pair, list) or len(pair) != 2 or not all(isinstance(s, str) and s for s in pair):
                raise ValueError('Invalid replacement pair: ' + key)
            if key == 'binary_pairs' and len(pair[0].encode()) != len(pair[1].encode()):
                raise ValueError('Binary replacements must preserve byte width')
        data[key] = [(a.encode(), b.encode()) for a, b in data[key]]
    return data


def process(args):
    root = args.root.resolve()
    config = load_mapping(args.mapping)
    paths = sorted({p for pattern in config['targets'] for p in root.glob(pattern) if p.is_file()})
    if not paths:
        raise ValueError('No input files')
    for p in paths:
        if not p.resolve().is_relative_to(root) or p.is_symlink():
            raise ValueError('Input escapes the owned source root')
    forbidden = [re.compile(s.encode(), re.I) for s in config['forbidden']]
    receipt = {'schema_version': 1, 'scope': str(root), 'apply': args.apply, 'compiled': False, 'packaged': False, 'installed': False, 'target_executed': False, 'files': []}
    environment = dict(os.environ)
    prefix = os.environ.get('PREFIX')
    if prefix:
        environment['LD_LIBRARY_PATH'] = str(Path(prefix) / 'lib')
    with tempfile.TemporaryDirectory(prefix='teec-native-rename-') as directory:
        scratch = Path(directory)
        staged = []
        for index, path in enumerate(paths):
            original = path.read_bytes()
            relative = path.relative_to(root)
            destination = root / replace(str(relative).encode(), config['filename_pairs']).decode()
            is_elf = original[:4] == b'\x7fELF'
            pairs = config['binary_pairs'] if is_elf else config['text_pairs']
            if original == replace(original, pairs) and path == destination:
                continue
            before = Elf(original) if is_elf else None
            renamed = {s['name']: replace(s['name'], pairs) for s in before.symbols if s['name'] != replace(s['name'], pairs)} if before else {}
            temporary = scratch / str(index)
            temporary.write_bytes(original)
            if renamed:
                names = scratch / (str(index) + '.map')
                names.write_bytes(b''.join(old + b' ' + new + b'\n' for old, new in renamed.items()))
                page_size = max(p[7] for p in before.programs if p[0] == 1)
                result = subprocess.run(['patchelf', '--page-size', str(page_size), '--rename-dynamic-symbols', str(names), str(temporary)], env=environment, capture_output=True, text=True)
                if result.returncode:
                    raise ValueError('patchelf failed for ' + str(relative) + ': ' + result.stderr.strip())
            data = replace(temporary.read_bytes(), pairs)
            for pattern in forbidden:
                if pattern.search(data) or pattern.search(destination.name.encode()):
                    raise ValueError('Unmapped retired identity remains in ' + str(relative))
            try:
                checked = compare(before, Elf(data), pairs) if is_elf else 0
            except ValueError as error:
                raise ValueError(str(relative) + ': ' + str(error)) from error
            if destination != path and destination.exists():
                raise ValueError('Rename destination already exists: ' + str(destination))
            temporary.write_bytes(data)
            temporary.chmod(path.stat().st_mode & 0o777)
            staged.append((path, destination, temporary, digest(original)))
            receipt['files'].append({'before': str(relative), 'after': str(destination.relative_to(root)), 'before_sha256': digest(original), 'after_sha256': digest(data), 'before_size': len(original), 'after_size': len(data), 'elf': is_elf, 'renamed_dynamic_symbols': len(renamed), 'hash_lookups_verified': checked, 'machine_code_unchanged': is_elf, 'symbol_addresses_and_relocations_preserved': is_elf})
        if args.apply:
            for path, destination, temporary, original_digest in staged:
                if digest(path.read_bytes()) != original_digest:
                    raise ValueError('Source changed during validation: ' + str(path))
            for path, destination, temporary, original_digest in staged:
                destination.parent.mkdir(parents=True, exist_ok=True)
                os.replace(temporary, destination)
                if destination != path:
                    path.unlink()
    receipt['changed_files'] = len(receipt['files'])
    receipt['elf_files'] = sum(record['elf'] for record in receipt['files'])
    receipt['renamed_dynamic_symbols'] = sum(record['renamed_dynamic_symbols'] for record in receipt['files'])
    receipt['hash_lookups_verified'] = sum(record['hash_lookups_verified'] for record in receipt['files'])
    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    args.receipt.write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({key: receipt[key] for key in ('apply', 'changed_files', 'elf_files', 'renamed_dynamic_symbols', 'hash_lookups_verified', 'compiled', 'target_executed')}))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--mapping', type=Path, required=True)
    parser.add_argument('--receipt', type=Path, required=True)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    process(args)


if __name__ == '__main__':
    main()
