set -Eeuo pipefail
umask 022

if [[ ${1:-build} == diagnose ]]; then
    set +e
    diagnostics=${2:?Expected the diagnostics directory}
    prefix=${OPAMROOT:-/root/.opam}/rocq-9.3.0
    build_root=$prefix/.opam-switch/build
    runtime_build=$build_root/rocq-runtime.9.3.0
    core_build=$build_root/rocq-core.9.3.0
    mkdir -p "$diagnostics/files" "$diagnostics/elf"
    date -u +%FT%TZ
    opam_environment=$(opam env --switch=rocq-9.3.0 --set-switch --shell=bash)
    eval "$opam_environment"
    ocamlc -config > "$diagnostics/ocaml-config.txt" 2>&1
    gdb --version > "$diagnostics/gdb-version.txt" 2>&1
    for package in rocq-runtime.9.3.0 rocq-core.9.3.0; do
        if [[ -f "$build_root/$package/_build/log" ]]; then
            cp "$build_root/$package/_build/log" "$diagnostics/$package.dune.log"
        fi
    done
    find "$runtime_build" "$core_build" -type f \
        \( -name rocq_values.c -o -name rocq_values.o -o -name libcoqrun_stubs.a \
        -o -name rocq_config.h -o -name coq_config.ml -o -name rocq_config.ml \
        -o -name rocqworker.exe -o -name rocqnative.exe -o -name rocq.exe \) \
        -print0 > "$diagnostics/runtime-files.nul"
    for installed in "$prefix/bin/rocq" "$prefix/lib/rocq-runtime/rocqworker" "$prefix/lib/rocq-runtime/rocqnative"; do
        if [[ -f "$installed" ]]; then
            printf '%s\0' "$installed" >> "$diagnostics/runtime-files.nul"
        fi
    done
    index=0
    while IFS= read -r -d '' retained; do
        index=$((index + 1))
        printf '%s\t%s\n' "$index" "$retained" >> "$diagnostics/runtime-files.txt"
        cp --parents --dereference "$retained" "$diagnostics/files"
        if file -b "$retained" | grep -Eq 'ELF|current ar archive'; then
            readelf --wide --file-header --section-headers --program-headers "$retained" > "$diagnostics/elf/$index.headers.txt" 2>&1
            readelf --wide --symbols "$retained" | grep -E 'Symbol table|rocq_curry2_1|caml_curry2_1' > "$diagnostics/elf/$index.symbols.txt"
            objdump -h "$retained" > "$diagnostics/elf/$index.sections.txt" 2>&1
            objdump -Dr --disassemble=rocq_curry2_1 "$retained" > "$diagnostics/elf/$index.trampoline.txt" 2>&1
            if [[ ${retained##*/} == rocq_values.o ]]; then
                objdump -Dr "$retained" > "$diagnostics/elf/$index.object-disassembly.txt" 2>&1
            fi
        fi
    done < "$diagnostics/runtime-files.nul"
    grep -n 'rocq_values\|native-compiler\|NO_NATIVE_COMPUTE' "$diagnostics/rocq-runtime.9.3.0.dune.log" > "$diagnostics/runtime-compiler-commands.txt"
    if [[ -d "$prefix/share/teec-toolchain-build" ]]; then
        cp -a "$prefix/share/teec-toolchain-build" "$diagnostics/provenance"
    fi
    if [[ -f "$core_build/_build/default/theories/Corelib/Init/Logic.v" && -x "$prefix/bin/rocq" ]]; then
        arguments=(c -noinit -boot -R theories/Corelib Corelib -w +default -q \
            -nI "$prefix/lib/rocq-runtime/kernel" -native-output-dir . \
            -w -deprecated-native-compiler-option -native-compiler on \
            -time-file theories/Corelib/Init/Logic.timing theories/Corelib/Init/Logic.v)
        printf 'cwd=%s\n' "$core_build/_build/default" > "$diagnostics/reproduction-command.txt"
        printf '%q ' "$prefix/bin/rocq" "${arguments[@]}" >> "$diagnostics/reproduction-command.txt"
        printf '\n' >> "$diagnostics/reproduction-command.txt"
        (
            cd "$core_build/_build/default" || exit
            timeout --signal=TERM --kill-after=10s 300s gdb --batch --nx \
                -ex 'set pagination off' -ex 'set confirm off' \
                -ex 'set disable-randomization off' \
                -ex 'set follow-fork-mode parent' -ex 'set follow-exec-mode same' \
                -ex 'set print elements 16' -ex 'set backtrace limit 25' \
                -ex 'handle SIGSEGV stop print nopass' \
                -ex run -ex 'bt 25' -ex 'info registers' -ex 'x/12i $pc' -ex 'x/4gx $x1' \
                -ex 'info address rocq_curry2_1' -ex 'info address caml_curry2_1' \
                -ex 'info proc mappings' -ex 'x/8i rocq_curry2_1' \
                -ex 'x/4gx (char *)&rocq_curry2_1-8' \
                --args "$prefix/bin/rocq" "${arguments[@]}"
        ) > "$diagnostics/gdb-corelib-logic.txt" 2>&1
        printf 'gdb_probe_status=%s\n' "$?"
    else
        printf '%s\n' 'Corelib Logic reproduction inputs unavailable.'
    fi
    date -u +%FT%TZ
    exit 0
fi

[[ ${EUID} -eq 0 ]] || { printf '%s\n' 'Run this script as container root.' >&2; exit 1; }
. /etc/os-release
[[ ${ID:-} == ubuntu && ${VERSION_ID:-} == 22.04 && ${VERSION_CODENAME:-} == jammy ]] || { printf '%s\n' 'Expected Ubuntu 22.04 jammy.' >&2; exit 1; }
[[ $(dpkg --print-architecture) == arm64 && $(uname -m) == aarch64 && $(getconf LONG_BIT) == 64 ]] || { printf '%s\n' 'Expected native 64-bit ARM64.' >&2; exit 1; }
[[ $(opam --version) == 2.1.2 ]] || { printf '%s\n' 'Expected Ubuntu 22.04 opam 2.1.2.' >&2; exit 1; }
[[ ! -e /root/.opam ]] || { printf '%s\n' 'Expected an unused /root/.opam prefix.' >&2; exit 1; }

export OPAMROOT=/root/.opam OPAMROOTISOK=1 OPAMJOBS=2 OPAMCOLOR=never
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS OCAMLPARAM
variant=${TEEC_ROCQ_VARIANT:-standard}
[[ $variant == standard || $variant == native-diagnostic ]] || { printf 'Unsupported variant: %s\n' "$variant" >&2; exit 2; }
archive_variant=standard
native_config=no
native_packages=()
if [[ $variant == native-diagnostic ]]; then
    archive_variant=teec-elf1
    native_config=yes
    native_packages=(rocq-native.3)
fi
output=$(pwd)/dist/prover-toolchains
build_script=$(readlink -f "${BASH_SOURCE[0]}")
mkdir -p "$output/verification"
evidence=$output/verification
exec > >(tee "$output/build.log") 2>&1
on_build_failure() {
    local status=$1
    trap - ERR
    set +e
    printf 'BUILD FAILED status=%s\n' "$status" >&2
    if [[ $variant == native-diagnostic && ${TEEC_ROCQ_DIAGNOSTICS:-0} == 1 ]] && mkdir "$output/.diagnostics-started" 2>/dev/null; then
        mkdir -p "$output/diagnostics"
        timeout --signal=TERM --kill-after=15s 585s bash "$build_script" diagnose "$output/diagnostics" \
            > "$output/diagnostics/probe.log" 2>&1
        printf 'DIAGNOSTIC status=%s original_build_status=%s\n' "$?" "$status" >&2
    fi
    exit "$status"
}
trap 'on_build_failure "$?"' ERR

opam init --bare --disable-sandboxing --no-setup --no-opamrc --yes default https://opam.ocaml.org
opam switch create rocq-9.3.0 --empty --yes
opam repository add --switch=rocq-9.3.0 --yes rocq-released https://rocq-prover.org/opam/released
runtime_source=$OPAMROOT/teec-sources/rocq-runtime.9.3.0
build_info=$OPAMROOT/rocq-9.3.0/share/teec-toolchain-build
runtime_patch=$(pwd)/.github/patches/rocq-9.3.0-arm64-elf-symbols.patch
upstream_url=https://github.com/rocq-prover/rocq/releases/download/V9.3.0/rocq-9.3.0.tar.gz
upstream_sha256=3f0fc283e8644394aa9c7a6e3995b6d9ebbe1e6dda712bf431f9c372dcef95ad
mkdir -p "$OPAMROOT/teec-sources" "$build_info"
curl --fail --location --retry 3 --output "$build_info/rocq-9.3.0.upstream.tar.gz" "$upstream_url"
printf '%s  %s\n' "$upstream_sha256" "$build_info/rocq-9.3.0.upstream.tar.gz" | sha256sum --check --strict
opam show --switch=rocq-9.3.0 --raw rocq-runtime.9.3.0 > "$build_info/rocq-runtime.upstream.opam"
opam source --switch=rocq-9.3.0 --dir="$runtime_source" rocq-runtime.9.3.0
python3 - "$build_info" "$runtime_source" <<'PY'
from pathlib import Path
import hashlib
import sys
import tarfile

provenance, source = map(Path, sys.argv[1:])
with tarfile.open(provenance / "rocq-9.3.0.upstream.tar.gz") as archive:
    candidates = [item for item in archive.getmembers() if item.name.endswith("/kernel/byterun/rocq_values.c")]
    assert len(candidates) == 1
    with archive.extractfile(candidates[0]) as member:
        original = member.read()
assert hashlib.sha256(original).hexdigest() == "34b074aa3e121cb077dbe92aa74b5b6b93f28ef0d9389ca2fffce01ca836a592"
assert (source / "kernel/byterun/rocq_values.c").read_bytes() == original
(provenance / "rocq_values.c.upstream").write_bytes(original)
print("official release archive and original ARM64 source: PASS")
PY
if [[ $variant == native-diagnostic ]]; then
cp "$runtime_patch" "$build_info/rocq-9.3.0-arm64-elf-symbols.patch"
patch --batch --forward --fuzz=0 --dry-run -p1 -d "$runtime_source" < "$runtime_patch"
patch --batch --forward --fuzz=0 -p1 -d "$runtime_source" < "$runtime_patch"
printf '%s  %s\n' 33c5e28ca517040cfc645d24c12c662aa1230fd940dfaf5dd2bb5accb470b28c "$runtime_source/kernel/byterun/rocq_values.c" | sha256sum --check --strict
cp "$runtime_source/kernel/byterun/rocq_values.c" "$build_info/rocq_values.c.teec-elf1"
patched_archive=$OPAMROOT/teec-sources/rocq-runtime.9.3.0-teec-elf1.tar.gz
local_repository=$OPAMROOT/teec-repository
local_package=$local_repository/packages/rocq-runtime/rocq-runtime.9.3.0
tar -C "$OPAMROOT/teec-sources" -czf "$patched_archive" rocq-runtime.9.3.0
mkdir -p "$local_package"
printf 'opam-version: "2.0"\n' > "$local_repository/repo"
python3 - "$build_info/rocq-runtime.upstream.opam" "$local_package/opam" "$upstream_url" "$upstream_sha256" "$patched_archive" <<'PY'
from pathlib import Path
import hashlib
import sys

original, target, upstream_url, upstream_hash, archive = sys.argv[1:]
metadata = Path(original).read_text()
assert metadata.count(upstream_url) == 1
assert metadata.count(upstream_hash) == 1
metadata = metadata.replace(upstream_url, Path(archive).as_uri())
metadata = metadata.replace(upstream_hash, hashlib.sha256(Path(archive).read_bytes()).hexdigest())
Path(target).write_text(metadata)
PY
cp "$local_package/opam" "$build_info/rocq-runtime.teec-elf1.opam"
opam repository add --switch=rocq-9.3.0 --rank=1 --yes teec-elf1 "file://$local_repository"
opam show --switch=rocq-9.3.0 --raw rocq-runtime.9.3.0 > "$build_info/rocq-runtime.selected.opam"
grep -Fq "file://$patched_archive" "$build_info/rocq-runtime.selected.opam"
{
    printf 'variant=%s\n' teec-elf1
    printf 'patch_origin=%s\n' local
    printf 'native_compute=%s\n' enabled
    printf 'upstream_release=%s\n' https://github.com/rocq-prover/rocq/releases/tag/V9.3.0
    printf 'upstream_archive=%s\n' "$upstream_url"
    printf 'related_upstream_pull_request=%s\n' https://github.com/rocq-prover/rocq/pull/22447
    printf 'source_commit=%s\n' "${GITHUB_SHA:?Expected the GitHub source commit}"
    printf 'patched_source=%s\n' "$runtime_source"
    printf 'local_repository=%s\n' "$local_repository"
    printf 'patched_archive=%s\n' "file://$patched_archive"
    sha256sum "$build_info/rocq-9.3.0.upstream.tar.gz" "$build_info/rocq_values.c.upstream" \
        "$build_info/rocq_values.c.teec-elf1" "$build_info/rocq-9.3.0-arm64-elf-symbols.patch" \
        "$build_info/rocq-runtime.upstream.opam" "$build_info/rocq-runtime.teec-elf1.opam" \
        "$build_info/rocq-runtime.selected.opam" "$patched_archive"
} > "$build_info/provenance.txt"
else
    opam show --switch=rocq-9.3.0 --raw rocq-runtime.9.3.0 > "$build_info/rocq-runtime.selected.opam"
    grep -Fq "$upstream_url" "$build_info/rocq-runtime.selected.opam"
    grep -Fq "$upstream_sha256" "$build_info/rocq-runtime.selected.opam"
    {
        printf 'variant=%s\n' standard
        printf 'patch_origin=%s\n' none
        printf 'native_compute=%s\n' disabled
        printf 'source_state=%s\n' stock
        printf 'upstream_release=%s\n' https://github.com/rocq-prover/rocq/releases/tag/V9.3.0
        printf 'upstream_archive=%s\n' "$upstream_url"
        printf 'source_commit=%s\n' "${GITHUB_SHA:?Expected the GitHub source commit}"
        sha256sum "$build_info/rocq-9.3.0.upstream.tar.gz" "$build_info/rocq_values.c.upstream" \
            "$build_info/rocq-runtime.upstream.opam" "$build_info/rocq-runtime.selected.opam"
    } > "$build_info/provenance.txt"
fi
opam install --switch=rocq-9.3.0 --yes --jobs=2 --keep-build-dir \
    ocaml-base-compiler.5.4.1 'dune<3.24' "${native_packages[@]}" rocq-prover rocq-core.9.3.0 rocq-stdlib.9.2.0 \
    coq-core.9.3.0 rocq-stdpp.1.13.0 'rocq-equations.1.3.2+9.3' rocq-mathcomp-ssreflect.2.6.0
cmp "$runtime_source/kernel/byterun/rocq_values.c" "$OPAMROOT/rocq-9.3.0/.opam-switch/build/rocq-runtime.9.3.0/kernel/byterun/rocq_values.c"
eval "$(opam env --switch=rocq-9.3.0 --set-switch --shell=bash)"

[[ $(opam switch show) == rocq-9.3.0 ]]
[[ $(opam var prefix) == /root/.opam/rocq-9.3.0 ]]
[[ $(ocamlc -version) == 5.4.1 && $(ocamlopt -version) == 5.4.1 ]]
opam list --installed --switch=rocq-9.3.0 --columns=name,version --color=never > "$evidence/opam-packages.txt"
python3 - "$evidence/opam-packages.txt" "$variant" <<'PY'
from pathlib import Path
import sys

packages = {}
for line in Path(sys.argv[1]).read_text().splitlines():
    if line.strip() and not line.lstrip().startswith("#"):
        name, version, *_ = line.split()
        packages[name] = version
expected = {
    "ocaml-base-compiler": "5.4.1",
    "rocq-runtime": "9.3.0",
    "rocq-core": "9.3.0",
    "rocq-stdlib": "9.2.0",
    "coq-core": "9.3.0",
    "rocq-stdpp": "1.13.0",
    "rocq-equations": "1.3.2+9.3",
    "rocq-mathcomp-ssreflect": "2.6.0",
}
if sys.argv[2] == "native-diagnostic":
    expected["rocq-native"] = "3"
else:
    assert "rocq-native" not in packages
for name, version in expected.items():
    assert packages.get(name) == version, (name, packages.get(name), version)
assert "rocq-prover" in packages
assert tuple(map(int, packages["dune"].split(".")[:2])) < (3, 24)
print("opam selected package versions: PASS")
PY

cat > "$evidence/ocaml_smoke.ml" <<'ML'
let () = assert (20 + 22 = 42); print_endline "OCaml execution: PASS"
ML
ocamlc -o "$evidence/ocaml_bytecode" "$evidence/ocaml_smoke.ml"
"$evidence/ocaml_bytecode"
ocamlopt -o "$evidence/ocaml_native" "$evidence/ocaml_smoke.ml"
"$evidence/ocaml_native"
readelf -h "$evidence/ocaml_native" | tee "$evidence/ocaml-native-elf.txt"
grep -Eq 'Machine:[[:space:]]+AArch64' "$evidence/ocaml-native-elf.txt"
rocq -v | tee "$evidence/rocq-version.txt"
grep -Eq 'version 9\.3\.0([[:space:]]|$)' "$evidence/rocq-version.txt"
coqc --version | tee "$evidence/coqc-version.txt"
grep -Eq 'version 9\.3\.0([[:space:]]|$)' "$evidence/coqc-version.txt"
rocq compile -config | tee "$evidence/rocq-config.txt"
grep -Fxq "COQ_NATIVE_COMPILER_DEFAULT=$native_config" "$evidence/rocq-config.txt"
computation=VMSmoke
computation_flags=()
if [[ $variant == native-diagnostic ]]; then
    computation=NativeSmoke
    computation_flags=(-native-compiler yes -w +native-compiler-disabled)
cat > "$evidence/NativeSmoke.v" <<'ROCQ'
From Stdlib Require Import Arith.PeanoNat.
Set NativeCompute Timing.
Example native_smoke : Nat.add 20 22 = 42.
Proof. native_compute. reflexivity. Qed.
ROCQ
else
cat > "$evidence/VMSmoke.v" <<'ROCQ'
From Stdlib Require Import Arith.PeanoNat.
Example vm_smoke : Nat.add 20 22 = 42.
Proof. vm_compute. reflexivity. Qed.
ROCQ
fi
cat > "$evidence/LibrariesSmoke.v" <<'ROCQ'
From stdpp Require Import base.
From Equations.Prop Require Import Equations.
Equations smoke_pred (n : nat) : nat :=
smoke_pred 0 := 0;
smoke_pred (S n) := n.
Example smoke_pred_ok : smoke_pred 3 = 2.
Proof. reflexivity. Qed.
From mathcomp Require Import ssreflect ssrnat.
Lemma libraries_smoke (n : nat) : n + 0 = n.
Proof. exact: addn0. Qed.
ROCQ
(
    cd "$evidence"
    rocq compile -q "${computation_flags[@]}" "$computation.v"
    rocq compile -q LibrariesSmoke.v
    rocq check "$computation" LibrariesSmoke
) 2>&1 | tee "$evidence/rocq-proofs.txt"
[[ -s "$evidence/$computation.vo" && -s "$evidence/LibrariesSmoke.vo" ]]
printf 'Rocq %s computation and library proofs: PASS\n' "$variant"

opam switch export --switch=rocq-9.3.0 --full "$output/opam-switch.export"
cp "$build_info/provenance.txt" "$output/rocq-build-provenance.txt"
{
    cat "$build_info/provenance.txt"
    date -u +%FT%TZ
    cat /etc/os-release
    uname -m
    dpkg --print-architecture
    getconf GNU_LIBC_VERSION
    gcc --version
    dpkg-query -W -f='${Package}\t${Version}\n'
    opam --version
    opam switch show
    opam var prefix
    opam repository list --all --color=never
    opam pin list --switch=rocq-9.3.0 --color=never
    opam list --installed --switch=rocq-9.3.0 --columns=name,version --color=never
    ocamlc -config
    ocamlopt -config
    dune --version
    rocq -v
    coqc --version
    rocq compile -config
} > "$output/versions.txt"
printf '%s\n' "${GITHUB_SHA:?Expected the GitHub source commit}" > "$output/source-commit.txt"

python3 - "$OPAMROOT/rocq-9.3.0" <<'PY'
from pathlib import Path
import shutil
import sys

prefix = Path(sys.argv[1])
licenses = prefix / "share/teec-toolchain-licenses"
copied = 0
for kind in ("build", "sources"):
    source = prefix / ".opam-switch" / kind
    for path in source.rglob("*"):
        if path.name.lower().startswith(("license", "licence", "copying", "copyright", "notice")) and path.is_file():
            target = licenses / kind / path.relative_to(source)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
            copied += 1
assert copied, "No upstream license files retained"
print(f"upstream license files retained: {copied}")
PY
rm -rf -- "$OPAMROOT/download-cache" "$OPAMROOT/rocq-9.3.0/.opam-switch/build" "$OPAMROOT/rocq-9.3.0/.opam-switch/sources"
bundle=rocq-9.3.0-$archive_variant-ocaml-5.4.1-ubuntu-22.04-arm64.tar.zst
tar -C / -cf - root/.opam | zstd -T2 -6 -o "$output/$bundle"
zstd --test "$output/$bundle"
tar --zstd -tf "$output/$bundle" > "$output/archive-files.txt"
python3 - "$output/archive-files.txt" "$variant" <<'PY'
from pathlib import Path
import sys

members = Path(sys.argv[1]).read_text().splitlines()
assert members and all(name.startswith("root/.opam/") and ".." not in name.split("/") for name in members)
required = {
    "root/.opam/config",
    "root/.opam/teec-sources/rocq-runtime.9.3.0/kernel/byterun/rocq_values.c",
    "root/.opam/rocq-9.3.0/.opam-switch/switch-state",
    "root/.opam/rocq-9.3.0/.opam-switch/switch-config",
    "root/.opam/rocq-9.3.0/.opam-switch/packages/rocq-runtime.9.3.0/opam",
    "root/.opam/rocq-9.3.0/bin/ocamlopt",
    "root/.opam/rocq-9.3.0/bin/rocq",
    "root/.opam/rocq-9.3.0/bin/coqc",
    "root/.opam/rocq-9.3.0/share/teec-toolchain-licenses/",
    "root/.opam/rocq-9.3.0/share/teec-toolchain-build/provenance.txt",
    "root/.opam/rocq-9.3.0/share/teec-toolchain-build/rocq-9.3.0.upstream.tar.gz",
}
if sys.argv[2] == "native-diagnostic":
    required.update({
        "root/.opam/teec-sources/rocq-runtime.9.3.0-teec-elf1.tar.gz",
        "root/.opam/teec-repository/packages/rocq-runtime/rocq-runtime.9.3.0/opam",
    })
else:
    assert not any(name.startswith("root/.opam/teec-repository/") or "teec-elf1" in name for name in members)
assert required.issubset(members), required.difference(members)
print("archive installed prefix and metadata: PASS")
PY
mv "$OPAMROOT" "$OPAMROOT.prearchive"
tar --zstd -xpf "$output/$bundle" -C /
[[ $(opam var prefix) == /root/.opam/rocq-9.3.0 ]]
opam list --installed --switch=rocq-9.3.0 --columns=name,version --color=never > "$evidence/extracted-opam-packages.txt"
diff -u "$evidence/opam-packages.txt" "$evidence/extracted-opam-packages.txt"
rocq compile -config > "$evidence/extracted-rocq-config.txt"
grep -Fxq "COQ_NATIVE_COMPILER_DEFAULT=$native_config" "$evidence/extracted-rocq-config.txt"
ocamlc -o "$evidence/ocaml_bytecode" "$evidence/ocaml_smoke.ml"
"$evidence/ocaml_bytecode"
ocamlopt -o "$evidence/ocaml_native" "$evidence/ocaml_smoke.ml"
"$evidence/ocaml_native"
(
    cd "$evidence"
    rm -rf -- .coq-native
    rm -f -- "$computation.vo" LibrariesSmoke.vo
    rocq compile -q "${computation_flags[@]}" "$computation.v"
    rocq compile -q LibrariesSmoke.v
    rocq check "$computation" LibrariesSmoke
) 2>&1 | tee "$evidence/extracted-rocq-proofs.txt"
[[ -s "$evidence/$computation.vo" && -s "$evidence/LibrariesSmoke.vo" ]]
rm -rf -- "$OPAMROOT.prearchive"
date -u +%FT%TZ > "$evidence/PASS"
(
    cd "$output"
    sha256sum "$bundle" versions.txt opam-switch.export source-commit.txt archive-files.txt rocq-build-provenance.txt > SHA256SUMS
    sha256sum --check --strict SHA256SUMS
)
printf 'BUILD PASS artifact=%s\n' "$output/$bundle"
