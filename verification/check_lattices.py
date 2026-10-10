"""Exact checks of the lattices behind E8Packing and LeechPacking, read from data/.

E8: the rows of data/e8.txt are 2 * E8Matrix; the lattice is their span divided by 2.
Leech: the rows of data/leech.txt are leechGeneratorMatrixInt; the lattice is their span
divided by sqrt 8.  For each lattice the program checks, in exact rational arithmetic, that
the Gram matrix is integral with even diagonal and determinant 1 (even unimodular), and then
evaluates the packing density vol(ball of radius separation/2) / covolume and compares it
with the value in the Lean theorems E8Packing_density and LeechPacking_density.
Usage: python3 -I check_lattices.py
"""
import math
from fractions import Fraction
from pathlib import Path

here = Path(__file__).resolve().parent
fails = 0


def check(name, ok):
    global fails
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")
    fails += not ok


def rows(name):
    return [[int(x) for x in line.split()] for line in (here / "data" / name).read_text().splitlines() if line.strip()]


def det(m):
    m = [[Fraction(x) for x in r] for r in m]
    n, d = len(m), Fraction(1)
    for i in range(n):
        p = next((r for r in range(i, n) if m[r][i] != 0), None)
        if p is None:
            return Fraction(0)
        if p != i:
            m[i], m[p] = m[p], m[i]
            d = -d
        d *= m[i][i]
        for r in range(i + 1, n):
            f = m[r][i] / m[i][i]
            if f:
                m[r] = [a - f * b for a, b in zip(m[r], m[i])]
    return d


def gram(r, scale):
    return [[Fraction(sum(a * b for a, b in zip(u, v)), scale) for v in r] for u in r]


def ball_volume(n, radius):
    return math.pi ** (n / 2) * radius ** n / math.gamma(n / 2 + 1)


for name, file, scale, sep, value, label in [
    ("E8", "e8.txt", 4, math.sqrt(2), math.pi ** 4 / 384, "pi^4/384"),
    ("Leech", "leech.txt", 8, 2.0, math.pi ** 12 / math.factorial(12), "pi^12/12!"),
]:
    r = rows(file)
    n = len(r)
    G = gram(r, scale)
    check(f"{name}: Gram matrix is integral", all(x.denominator == 1 for row in G for x in row))
    check(f"{name}: Gram matrix has even diagonal", all(G[i][i] % 2 == 0 for i in range(n)))
    d = det(G)
    check(f"{name}: det(Gram) = 1, so the lattice is unimodular (covolume 1)", d == 1)
    dens = ball_volume(n, sep / 2) / math.sqrt(d)
    check(f"{name}: density with separation {sep:.6g} is {label} = {value:.12g}", abs(dens - value) < 1e-12 * value)

# E8Lattice is the image of Submodule.E8: vectors with all coordinates in Z or all in Z + 1/2
# and even coordinate sum.  Check that every generator row has that form.
e8 = rows("e8.txt")
same_parity = all(len({x % 2 for x in r}) == 1 for r in e8)
even_sum = all(sum(r) % 4 == 0 for r in e8)
check("E8: generators lie in D8 or D8 + (1/2,...,1/2) with even coordinate sum", same_parity and even_sum)
# The Leech generators have norms 4 or 8 after scaling, and the 24th row is Conway's (-3, 1^23)/sqrt 8.
le = rows("leech.txt")
check("Leech: generator norms are 4 or 8", all(sum(x * x for x in r) in (32, 64) for r in le))
check("Leech: last generator is (-3, 1, ..., 1)", le[-1] == [-3] + [1] * 23)
print(f"\n{'all checks passed' if not fails else f'{fails} checks FAILED'}")
raise SystemExit(1 if fails else 0)
