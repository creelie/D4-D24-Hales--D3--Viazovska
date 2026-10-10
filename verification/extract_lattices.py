"""Extract the E8 and Leech generator matrices from the Lean sources of sphere-packing/.

Writes data/e8.txt (rows of 2 * E8Matrix, integers) and data/leech.txt (rows of
leechGeneratorMatrixInt, integers; the lattice is their span scaled by 1/sqrt 8).
With --check, compares against the committed files instead of writing them.
Usage: python3 -I extract_lattices.py [--check] [path-to-sphere-packing]
"""
import re
import sys
from fractions import Fraction
from pathlib import Path

args = [a for a in sys.argv[1:] if a != "--check"]
check = "--check" in sys.argv
here = Path(__file__).resolve().parent
root = Path(args[0]) if args else here.parent / "sphere-packing"


def block(text, start, end):
    i = text.index(start)
    j = text.index(end, i)
    return text[i:j]


def e8_rows():
    src = (root / "SpherePacking/Dim8/E8/Basic.lean").read_text()
    body = block(src, "public def E8Matrix", "/-- Each row")
    body = body.split("!![", 1)[1].rsplit("]", 1)[0]
    rows = []
    for line in body.split(";"):
        entries = [e.strip() for e in line.split(",") if e.strip()]
        row = []
        for e in entries:
            row.append(Fraction(1, 2) if e == "2⁻¹" else Fraction(int(e)))
        rows.append(row)
    assert len(rows) == 8 and all(len(r) == 8 for r in rows), rows
    return [[int(2 * x) for x in r] for r in rows]


def leech_rows():
    src = (root / "SpherePacking/Dim24/LeechLattice/Defs.lean").read_text()
    body = block(src, "public def leechGeneratorMatrixInt", "/-- Rows of")
    rows = [[int(x) for x in m.split(",")] for m in re.findall(r"!\[([-0-9, ]+)\]", body)]
    assert len(rows) == 24 and all(len(r) == 24 for r in rows), len(rows)
    return rows


def fmt(rows):
    return "".join(" ".join(str(x) for x in r) + "\n" for r in rows)


out = {"e8.txt": fmt(e8_rows()), "leech.txt": fmt(leech_rows())}
bad = 0
for name, text in out.items():
    path = here / "data" / name
    if check:
        same = path.read_text() == text
        print(f"{name}: {'matches the Lean source' if same else 'DIFFERS from the Lean source'}")
        bad += not same
    else:
        path.write_text(text)
        print(f"wrote {path}")
sys.exit(1 if bad else 0)
