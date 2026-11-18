set -Eeuo pipefail
umask 022

[[ ${EUID} -eq 0 ]] || { printf '%s\n' 'Run this script as container root.' >&2; exit 1; }
. /etc/os-release
[[ ${ID:-} == ubuntu && ${VERSION_ID:-} == 22.04 && ${VERSION_CODENAME:-} == jammy ]] || { printf '%s\n' 'Expected Ubuntu 22.04 jammy.' >&2; exit 1; }
[[ $(dpkg --print-architecture) == arm64 && $(uname -m) == aarch64 && $(getconf LONG_BIT) == 64 ]] || { printf '%s\n' 'Expected native 64-bit ARM64.' >&2; exit 1; }
[[ $(opam --version) == 2.1.2 ]] || { printf '%s\n' 'Expected Ubuntu 22.04 opam 2.1.2.' >&2; exit 1; }
[[ ! -e /root/.opam ]] || { printf '%s\n' 'Expected an unused /root/.opam prefix.' >&2; exit 1; }

export OPAMROOT=/root/.opam OPAMROOTISOK=1 OPAMJOBS=2 OPAMCOLOR=never
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS OCAMLPARAM
output=$(pwd)/dist/prover-toolchains
mkdir -p "$output/verification"
evidence=$output/verification
exec > >(tee "$output/build.log") 2>&1
trap 'status=$?; printf "BUILD FAILED status=%s\n" "$status" >&2; exit "$status"' ERR

opam init --bare --disable-sandboxing --no-setup --no-opamrc --yes default https://opam.ocaml.org
opam switch create rocq-9.3.0 --empty --yes
opam repository add --switch=rocq-9.3.0 --yes rocq-released https://rocq-prover.org/opam/released
opam install --switch=rocq-9.3.0 --yes --jobs=2 --keep-build-dir \
    ocaml-base-compiler.5.4.1 'dune<3.24' rocq-native.3 rocq-prover rocq-core.9.3.0 rocq-stdlib.9.2.0 \
    coq-core.9.3.0 rocq-stdpp.1.13.0 'rocq-equations.1.3.2+9.3' rocq-mathcomp-ssreflect.2.6.0
eval "$(opam env --switch=rocq-9.3.0 --set-switch --shell=bash)"

[[ $(opam switch show) == rocq-9.3.0 ]]
[[ $(opam var prefix) == /root/.opam/rocq-9.3.0 ]]
[[ $(ocamlc -version) == 5.4.1 && $(ocamlopt -version) == 5.4.1 ]]
opam list --installed --switch=rocq-9.3.0 --columns=name,version --color=never > "$evidence/opam-packages.txt"
python3 - "$evidence/opam-packages.txt" <<'PY'
from pathlib import Path
import sys

packages = {}
for line in Path(sys.argv[1]).read_text().splitlines():
    if line.strip() and not line.lstrip().startswith("#"):
        name, version, *_ = line.split()
        packages[name] = version
expected = {
    "ocaml-base-compiler": "5.4.1",
    "rocq-native": "3",
    "rocq-runtime": "9.3.0",
    "rocq-core": "9.3.0",
    "rocq-stdlib": "9.2.0",
    "coq-core": "9.3.0",
    "rocq-stdpp": "1.13.0",
    "rocq-equations": "1.3.2+9.3",
    "rocq-mathcomp-ssreflect": "2.6.0",
}
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
cat > "$evidence/NativeSmoke.v" <<'ROCQ'
From Stdlib Require Import Arith.PeanoNat.
Set NativeCompute Timing.
Example native_smoke : Nat.add 20 22 = 42.
Proof. native_compute. reflexivity. Qed.
ROCQ
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
    rocq compile -q -native-compiler yes -w +native-compiler-disabled NativeSmoke.v
    rocq compile -q LibrariesSmoke.v
    rocq check NativeSmoke LibrariesSmoke
) 2>&1 | tee "$evidence/rocq-proofs.txt"
[[ -s "$evidence/NativeSmoke.vo" && -s "$evidence/LibrariesSmoke.vo" ]]
printf '%s\n' 'Rocq native_compute and library proofs: PASS'

opam switch export --switch=rocq-9.3.0 --full "$output/opam-switch.export"
{
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
bundle=rocq-9.3.0-ocaml-5.4.1-ubuntu-22.04-arm64.tar.zst
tar -C / -cf - root/.opam | zstd -T2 -6 -o "$output/$bundle"
zstd --test "$output/$bundle"
tar --zstd -tf "$output/$bundle" > "$output/archive-files.txt"
python3 - "$output/archive-files.txt" <<'PY'
from pathlib import Path
import sys

members = Path(sys.argv[1]).read_text().splitlines()
assert members and all(name.startswith("root/.opam/") and ".." not in name.split("/") for name in members)
required = {
    "root/.opam/config",
    "root/.opam/rocq-9.3.0/.opam-switch/switch-state",
    "root/.opam/rocq-9.3.0/.opam-switch/switch-config",
    "root/.opam/rocq-9.3.0/.opam-switch/packages/rocq-runtime.9.3.0/opam",
    "root/.opam/rocq-9.3.0/bin/ocamlopt",
    "root/.opam/rocq-9.3.0/bin/rocq",
    "root/.opam/rocq-9.3.0/bin/coqc",
    "root/.opam/rocq-9.3.0/share/teec-toolchain-licenses/",
}
assert required.issubset(members), required.difference(members)
print("archive installed prefix and metadata: PASS")
PY
mv "$OPAMROOT" "$OPAMROOT.prearchive"
tar --zstd -xpf "$output/$bundle" -C /
[[ $(opam var prefix) == /root/.opam/rocq-9.3.0 ]]
opam list --installed --switch=rocq-9.3.0 --columns=name,version --color=never > "$evidence/extracted-opam-packages.txt"
diff -u "$evidence/opam-packages.txt" "$evidence/extracted-opam-packages.txt"
ocamlc -o "$evidence/ocaml_bytecode" "$evidence/ocaml_smoke.ml"
"$evidence/ocaml_bytecode"
ocamlopt -o "$evidence/ocaml_native" "$evidence/ocaml_smoke.ml"
"$evidence/ocaml_native"
(
    cd "$evidence"
    rm -rf -- .coq-native
    rm -f -- NativeSmoke.vo LibrariesSmoke.vo
    rocq compile -q -native-compiler yes -w +native-compiler-disabled NativeSmoke.v
    rocq compile -q LibrariesSmoke.v
    rocq check NativeSmoke LibrariesSmoke
) 2>&1 | tee "$evidence/extracted-rocq-proofs.txt"
[[ -s "$evidence/NativeSmoke.vo" && -s "$evidence/LibrariesSmoke.vo" ]]
rm -rf -- "$OPAMROOT.prearchive"
date -u +%FT%TZ > "$evidence/PASS"
(
    cd "$output"
    sha256sum "$bundle" versions.txt opam-switch.export source-commit.txt archive-files.txt > SHA256SUMS
    sha256sum --check --strict SHA256SUMS
)
printf 'BUILD PASS artifact=%s\n' "$output/$bundle"
