#!/usr/bin/env bash
# run_all.sh -- the checks of this repository that do not need the Lean build.
#
#   shell   scan.sh               no sorry, axiom, native_decide, unsafe, ... in sphere-packing/
#   Python  extract_lattices.py   data/ matches E8Matrix and leechGeneratorMatrixInt in the Lean source
#   Python  check_lattices.py     E8 and Leech: integral even Gram matrix, determinant 1, densities
#                                 pi^4/384 and pi^12/12! (exact rationals)
#   Julia   check_lattices.jl     the same in Rational{BigInt} and 256-bit BigFloat (if julia is found)
#   C       e8_box.c              every vector of norm <= 4 of the E8 lattice by a box search:
#                                 240 of norm 2, 2160 of norm 4
#   C++     shortvectors.cpp      LLL + Fincke-Pohst: E8 (240, 2160) and Leech (no vector of norm 2,
#                                 196560 of norm 4), norms checked exactly in integers
# The Lean build itself runs in CI (.github/workflows/lean.yml).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD="${BUILD:-$HERE/../build}"
mkdir -p "$BUILD"
FAILED=0
fail() { echo "FAIL: $*"; FAILED=1; }
ok() { echo "ok:   $*"; }
cd "$HERE"

bash scan.sh > "$BUILD/scan.txt" 2>&1 && ok "scan.sh: $(grep -o 'scanning .* lines' "$BUILD/scan.txt"), clean" || fail "scan.sh (see build/scan.txt)"
python3 -I extract_lattices.py --check > "$BUILD/extract.txt" 2>&1 && ok "data/ matches the Lean source" || fail "extract_lattices.py (see build/extract.txt)"
python3 -I check_lattices.py > "$BUILD/py.txt" 2>&1 && ok "check_lattices.py" || fail "check_lattices.py (see build/py.txt)"
JULIA="${JULIA:-$(command -v julia || true)}"
if [ -z "$JULIA" ]; then echo "julia not found: skipping"; else
  "$JULIA" check_lattices.jl > "$BUILD/jl.txt" 2>&1 && ok "check_lattices.jl" || fail "check_lattices.jl (see build/jl.txt)"
fi
cc -O2 -std=c99 -Wall -o "$BUILD/e8_box" e8_box.c || fail "compile e8_box.c"
"$BUILD/e8_box" data/e8.txt > "$BUILD/c.txt" 2>&1 && ok "e8_box.c: 240 roots, 2160 of norm 4" || fail "e8_box.c (see build/c.txt)"
c++ -O2 -std=c++17 -Wall -o "$BUILD/shortvectors" shortvectors.cpp || fail "compile shortvectors.cpp"
"$BUILD/shortvectors" data/e8.txt 4 4 > "$BUILD/cpp-e8.txt" 2>&1
[ "$(grep '^norm' "$BUILD/cpp-e8.txt")" = "$(printf 'norm 8/4 : 240 vectors\nnorm 16/4 : 2160 vectors')" ] \
  && ok "shortvectors.cpp E8: 240 of norm 2, 2160 of norm 4" || fail "shortvectors.cpp E8 (see build/cpp-e8.txt)"
"$BUILD/shortvectors" data/leech.txt 8 4 > "$BUILD/cpp-leech.txt" 2>&1
[ "$(grep '^norm' "$BUILD/cpp-leech.txt")" = "norm 32/8 : 196560 vectors" ] \
  && ok "shortvectors.cpp Leech: no vector of norm 2, 196560 of norm 4" || fail "shortvectors.cpp Leech (see build/cpp-leech.txt)"

if [ $FAILED -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit $FAILED
