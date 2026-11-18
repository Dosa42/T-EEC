set -Eeuo pipefail
umask 022

[[ ${EUID} -eq 0 ]] || { printf '%s\n' 'Run this script as container root.' >&2; exit 1; }
. /etc/os-release
[[ ${ID:-} == ubuntu && ${VERSION_ID:-} == 22.04 && ${VERSION_CODENAME:-} == jammy ]] || { printf '%s\n' 'Expected Ubuntu 22.04 jammy.' >&2; exit 1; }
[[ $(dpkg --print-architecture) == arm64 && $(uname -m) == aarch64 && $(getconf LONG_BIT) == 64 ]] || { printf '%s\n' 'Expected native 64-bit ARM64.' >&2; exit 1; }
[[ $(getconf GNU_LIBC_VERSION) == 'glibc 2.35' ]] || { printf '%s\n' 'Expected the glibc 2.35 baseline.' >&2; exit 1; }
[[ ! -e /root/.elan && ! -e /opt/mathlib4 ]] || { printf '%s\n' 'Expected unused Lean and Mathlib prefixes.' >&2; exit 1; }

export ELAN_HOME=/root/.elan LEAN_NUM_THREADS=2 MATHLIB_NO_CACHE_ON_UPDATE=1 MATHLIB_CACHE_PARALLEL_MAX=4
unset LEAN_PATH LEAN_SRC_PATH LEAN_SYSROOT LD_LIBRARY_PATH CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
output=$(pwd)/dist/lean-cache
mkdir -p "$output/verification"
evidence=$output/verification
scratch=$(mktemp -d /tmp/teec-lean-cache.XXXXXXXX)
stage=$scratch/teec-lean-cache
mkdir -p "$stage/bin" "$stage/lib" "$stage/licenses" "$stage/metadata" "$stage/workspace/.lake"
exec > >(tee "$output/build.log") 2>&1
trap 'status=$?; printf "BUILD FAILED status=%s scratch=%s\n" "$status" "$scratch" >&2; exit "$status"' ERR

elan_archive=$scratch/elan-aarch64-unknown-linux-gnu.tar.gz
curl --fail --location --retry 5 --retry-delay 2 \
    https://github.com/leanprover/elan/releases/download/v4.4.0/elan-aarch64-unknown-linux-gnu.tar.gz \
    --output "$elan_archive"
printf '%s  %s\n' 45cde3006f82f98804c94cf2ca4949d117060a5f3cc8afa62f523759947ee21f "$elan_archive" | sha256sum --check --strict
mkdir "$scratch/elan"
tar -xzf "$elan_archive" -C "$scratch/elan"
"$scratch/elan/elan-init" -y --no-modify-path --default-toolchain leanprover/lean4:v4.36.0
export PATH="$ELAN_HOME/bin:$PATH"
elan --version | tee "$evidence/elan-version.txt"
grep -Eq '^elan 4\.4\.0([[:space:]]|$)' "$evidence/elan-version.txt"
lean --version | tee "$evidence/lean-version.txt"
grep -Eq '^Lean \(version 4\.36\.0([,[:space:]]|$)' "$evidence/lean-version.txt"
lean_prefix=$(lean --print-prefix)
[[ $lean_prefix == /root/.elan/toolchains/leanprover--lean4---v4.36.0 ]]
[[ -x $lean_prefix/bin/leantar ]]
export PATH="$lean_prefix/bin:$PATH"

git clone --depth 1 --branch v4.36.0 https://github.com/leanprover-community/mathlib4.git /opt/mathlib4
cd /opt/mathlib4
[[ $(git rev-parse HEAD) == fc4f59e577feb1a4956671bc04ac18aaaf8cd842 ]]
[[ $(git describe --tags --exact-match) == v4.36.0 ]]
[[ $(cat lean-toolchain) == leanprover/lean4:v4.36.0 ]]
cp lake-manifest.json "$evidence/lake-manifest.before.json"
LEAN_NUM_THREADS=2 lake build cache
cmp lake-manifest.json "$evidence/lake-manifest.before.json"
[[ -x .lake/build/bin/cache ]]
cp -a .lake/build/bin/cache "$stage/bin/cache"
cp -a "$lean_prefix/bin/leantar" "$stage/bin/leantar"
cp -a .lake/config "$stage/workspace/.lake/config"
python3 - "$stage" <<'PY'
from pathlib import Path
import shutil
import sys

stage = Path(sys.argv[1])
build = Path('/opt/mathlib4/.lake/build')
for pattern in ('bin/cache*', 'lib/lean/Cache*', 'ir/Cache*'):
    for source in build.glob(pattern):
        target = stage / 'workspace/.lake/build' / source.relative_to(build)
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            shutil.copytree(source, target, symlinks=True)
        else:
            shutil.copy2(source, target)
print('Bundled workspace cache bytes:', sum(path.stat().st_size for path in (stage / 'workspace').rglob('*') if path.is_file()))
PY

python3 - "$stage" "$evidence" "$lean_prefix" <<'PY'
from pathlib import Path
import hashlib
import re
import shutil
import subprocess
import sys

stage, evidence, lean_prefix = map(Path, sys.argv[1:])
queue = [(Path('/opt/mathlib4/.lake/build/bin/cache'), stage / 'bin/cache'), (lean_prefix / 'bin/leantar', stage / 'bin/leantar')]
seen = set()
report = []
while queue:
    binary, bundled = queue.pop(0)
    if binary in seen:
        continue
    seen.add(binary)
    header = subprocess.check_output(['readelf', '-h', str(binary)], text=True)
    assert re.search(r'Machine:\s+AArch64', header), str(binary)
    dynamic = subprocess.check_output(['readelf', '-d', str(binary)], text=True)
    versions = subprocess.check_output(['readelf', '--version-info', str(binary)], text=True)
    required = [tuple(map(int, version.split('.'))) for version in re.findall(r'GLIBC_(\d+(?:\.\d+)+)', versions)]
    assert all(version <= (2, 35) for version in required), (str(binary), required)
    result = subprocess.run(['ldd', str(binary)], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    assert 'not found' not in result.stdout, result.stdout
    assert result.returncode == 0 or 'There is no dynamic section' in dynamic, result.stdout
    report.append(f'{bundled.relative_to(stage)} (source: {binary})\n{header}\n{dynamic}\n{versions}\n{result.stdout}')
    for line in result.stdout.splitlines():
        match = re.search(r'(?:=>\s+)?(/\S+)', line)
        if not match:
            continue
        dependency = Path(match.group(1))
        resolved = dependency.resolve(strict=True)
        if resolved.is_relative_to('/usr/lib') or resolved.is_relative_to('/lib'):
            continue
        target = stage / 'lib' / dependency.name
        if target.exists():
            assert hashlib.sha256(target.read_bytes()).digest() == hashlib.sha256(resolved.read_bytes()).digest(), str(target)
        else:
            shutil.copy2(resolved, target)
            queue.append((resolved, target))
(evidence / 'elf-dependencies.txt').write_text('\n'.join(report))
print(f'ARM64/glibc/runtime dependency checks: PASS ({len(seen)} ELF files)')
PY

export LD_LIBRARY_PATH="$stage/lib"
export LEAN_SRC_PATH=/opt/mathlib4
for dependency in /opt/mathlib4/.lake/packages/*; do
    [[ -d $dependency ]] && LEAN_SRC_PATH="$LEAN_SRC_PATH:$dependency"
done
export MATHLIB_CACHE_DIR="$scratch/cache-smoke"
"$stage/bin/cache" --help > "$evidence/cache-help.txt"
grep -q 'Mathlib4 caching CLI' "$evidence/cache-help.txt"
"$stage/bin/cache" get- Mathlib.Algebra.Group.Basic 2>&1 | tee "$evidence/cache-get-smoke.txt"
grep -Fxq 'Downloaded all files successfully!' "$evidence/cache-get-smoke.txt"
python3 - "$MATHLIB_CACHE_DIR" "$evidence" <<'PY'
from pathlib import Path
import json
import sys

cache, evidence = map(Path, sys.argv[1:])
archives = sorted(str(path) for path in cache.glob('*.ltar'))
assert archives, 'Direct cache smoke downloaded no archives'
(evidence / 'leantar-smoke-input.json').write_text(json.dumps(archives) + '\n')
print(f'Direct cache download: PASS ({len(archives)} archives)')
PY
"$stage/bin/leantar" --jobs 1 -x --delete-corrupted -j - < "$evidence/leantar-smoke-input.json" 2>&1 | tee "$evidence/leantar-smoke.txt"
[[ -s .lake/build/lib/lean/Mathlib/Algebra/Group/Basic.olean ]]
export LEAN_PATH=/opt/mathlib4/.lake/build/lib/lean
for dependency in /opt/mathlib4/.lake/packages/*; do
    [[ -d $dependency ]] && LEAN_PATH="$LEAN_PATH:$dependency/.lake/build/lib/lean"
done
cat > "$evidence/LeanCacheSmoke.lean" <<'LEAN'
import Mathlib.Algebra.Group.Basic
example {G : Type} [Group G] (a : G) : a * 1 = a := mul_one a
LEAN
lean -j1 "$evidence/LeanCacheSmoke.lean" 2>&1 | tee "$evidence/lean-proof-smoke.txt"

cp lean-toolchain lake-manifest.json "$stage/metadata/"
python3 - "$stage/licenses" "$lean_prefix" <<'PY'
from pathlib import Path
import shutil
import sys

destination, lean_prefix = map(Path, sys.argv[1:])
roots = [('mathlib', Path('/opt/mathlib4')), ('lean', lean_prefix)]
roots += [(f'dependencies/{path.name}', path) for path in Path('/opt/mathlib4/.lake/packages').iterdir() if path.is_dir()]
for name, root in roots:
    retained = 0
    for path in root.iterdir():
        if path.name.lower().startswith(('license', 'licence', 'copying', 'copyright', 'notice')):
            target = destination / name / path.name
            target.parent.mkdir(parents=True, exist_ok=True)
            if path.is_dir():
                shutil.copytree(path, target, symlinks=True)
            else:
                shutil.copy2(path, target)
            retained += 1
    assert retained, f'No upstream license retained for {name}'
PY

{
    date -u +%FT%TZ
    cat /etc/os-release
    uname -m
    getconf GNU_LIBC_VERSION
    elan --version
    lean --version
    lake --version
    lean --print-prefix
    "$stage/bin/leantar" --version
    git rev-parse HEAD
    git describe --tags --exact-match
    dpkg-query -W -f='${Package}\t${Version}\n'
} > "$stage/metadata/versions.txt"
printf '%s\n' "${GITHUB_SHA:?Expected the GitHub source commit}" > "$stage/metadata/source-commit.txt"
python3 - "$stage" "$evidence" <<'PY'
from pathlib import Path
import json
import subprocess
import sys
import jsonschema

stage, evidence = map(Path, sys.argv[1:])
manifest = json.loads(Path('/opt/mathlib4/lake-manifest.json').read_text())
dependencies = []
for package in manifest['packages']:
    path = Path('/opt/mathlib4/.lake/packages') / package['name']
    actual = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], text=True).strip()
    assert actual == package['rev'], (package['name'], actual, package['rev'])
    dependencies.append({'name': package['name'], 'commit': actual})
record = {
    'schema': 'teec.lean-cache-artifact/1',
    'lean_toolchain': 'leanprover/lean4:v4.36.0',
    'elan_version': '4.4.0',
    'mathlib_tag': 'v4.36.0',
    'mathlib_commit': 'fc4f59e577feb1a4956671bc04ac18aaaf8cd842',
    'architecture': 'aarch64',
    'os': 'ubuntu:22.04',
    'glibc': '2.35',
    'workspace': '/opt/mathlib4',
    'lean_prefix': '/root/.elan/toolchains/leanprover--lean4---v4.36.0',
    'dependencies': dependencies,
    'bundled_runtime_libraries': sorted(path.name for path in (stage / 'lib').iterdir()),
    'executed_checks': ['cache --help', 'cache get- Mathlib.Algebra.Group.Basic', 'leantar --jobs 1 -x --delete-corrupted -j -', 'lean -j1 LeanCacheSmoke.lean'],
}
schema = {
    '$schema': 'https://json-schema.org/draft/2020-12/schema',
    'type': 'object',
    'properties': {key: {'const': value} for key, value in record.items() if key not in ('dependencies', 'bundled_runtime_libraries')},
    'required': list(record),
    'additionalProperties': False,
}
schema['properties']['dependencies'] = {
    'type': 'array', 'minItems': 1, 'uniqueItems': True,
    'items': {'type': 'object', 'properties': {'name': {'type': 'string', 'minLength': 1}, 'commit': {'type': 'string', 'pattern': '^[0-9a-f]{40}$'}}, 'required': ['name', 'commit'], 'additionalProperties': False},
}
schema['properties']['bundled_runtime_libraries'] = {'type': 'array', 'uniqueItems': True, 'items': {'type': 'string', 'pattern': '^[^/]+$'}}
jsonschema.Draft202012Validator.check_schema(schema)
jsonschema.Draft202012Validator(schema).validate(record)
(stage / 'metadata/manifest.schema.json').write_text(json.dumps(schema, indent=2) + '\n')
(stage / 'metadata/manifest.json').write_text(json.dumps(record, indent=2) + '\n')
for path in evidence.iterdir():
    if path.is_file() and path.suffix != '.json':
        (stage / 'metadata' / path.name).write_bytes(path.read_bytes())
print('Pinned dependency commits and artifact manifest: PASS')
PY

bundle=lean-cache-4.36.0-ubuntu-22.04-arm64.tar.zst
tar -C "$scratch" -cf - teec-lean-cache | zstd -T2 -6 -o "$output/$bundle"
zstd --test "$output/$bundle"
tar --zstd -tf "$output/$bundle" > "$output/archive-files.txt"
python3 - "$output/archive-files.txt" <<'PY'
from pathlib import Path
import sys

members = Path(sys.argv[1]).read_text().splitlines()
assert members and all(name.startswith('teec-lean-cache/') and '..' not in name.split('/') for name in members)
assert {'teec-lean-cache/bin/cache', 'teec-lean-cache/bin/leantar', 'teec-lean-cache/metadata/manifest.json', 'teec-lean-cache/metadata/manifest.schema.json', 'teec-lean-cache/workspace/.lake/config/', 'teec-lean-cache/licenses/mathlib/LICENSE'}.issubset(members)
assert not any('/lib/lean/Mathlib/' in name or name.endswith('.ltar') for name in members)
print('Small helper archive layout: PASS')
PY
cp "$stage/metadata/manifest.json" "$stage/metadata/manifest.schema.json" "$stage/metadata/versions.txt" "$output/"
date -u +%FT%TZ > "$evidence/PASS"
(
    cd "$output"
    sha256sum "$bundle" manifest.json manifest.schema.json versions.txt archive-files.txt > SHA256SUMS
    sha256sum --check --strict SHA256SUMS
)
printf 'BUILD PASS artifact=%s\n' "$output/$bundle"
