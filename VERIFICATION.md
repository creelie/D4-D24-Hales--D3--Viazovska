# Verification of the formal proofs in dimensions 8 and 24

Checked on 10 October 2026 against `sphere-packing/` at commit `1e98fb4` of math-inc/Sphere-Packing-Lean.
A formal proof is only as good as three things: the kernel accepted every step, no extra axiom or
`sorry` slipped in, and the formal statement says what the mathematics says. Each is checked
separately below.

## 1. Build and kernel

Done in CI (`.github/workflows/lean.yml`, job "Lean build, axioms and kernel replay"):

- `lake exe cache get` and `lake build` of all 830 files with Lean v4.28.0 and Mathlib v4.28.0;
- `verification/Statements.lean` (the restated theorems below) and the upstream `check_axioms.lean`,
  with `#print axioms` on every headline theorem; `verification/check_axioms_log.py` fails the job if any
  axiom other than `propext`, `Classical.choice`, `Quot.sound` appears;
- `leanchecker` (shipped with Lean from v4.28.0) on every one of the 828 modules under `SpherePacking/`
  (the root file `SpherePacking.lean` only imports them),
  which replays each module's declarations through the kernel again and catches environment hacking.

The results of the CI run are recorded at the end of this file.

## 2. Static scan

`verification/scan.sh` greps all 180,649 lines for anything that could bypass the kernel or add
assumptions. Comment lines are skipped.

| Pattern | Hits |
|---|---|
| `sorry` | 0 |
| `admit` (tactic) | 0 |
| new `axiom` declarations | 0 |
| `native_decide`, `Lean.ofReduceBool` | 0 |
| `implemented_by`, `@[extern]` | 0 |
| `unsafe`, `opaque` | 0 |
| `set_option debug.*`, `skipKernelTC` | 0 |
| `run_cmd`, `run_elab`, `addDecl` | 0 |
| `bv_decide` | 0 |
| `decide +kernel` | 30, allowed: the kernel evaluates these itself |

The 11 custom `macro`/`elab` definitions are `simp`/`norm_num` wrappers and a complex-number
normalizer (`SpherePacking/Tactic/NormNumI.lean`). They all produce ordinary proof terms that the
kernel checks.

## 3. Statement audit

The headline theorems are `SpherePacking.Dim8.MainTheorem : SpherePackingConstant 8 = E8Packing.density`
and `SpherePacking.Dim24.MainTheorem`. `verification/Statements.lean` chains them with the upstream lemmas
`E8Packing_density` and `LeechPacking_density`, so that the statements carry the numbers π⁴/384 and
π¹²/12!. The definitions they rest on (`SpherePacking/Basic/SpherePacking.lean`) were read line by line.

- **`SpherePacking d`** is a set of centres in ℝᵈ (`EuclideanSpace ℝ (Fin d)`) and a separation s > 0,
  with every two distinct centres at distance at least s. The balls are the open balls of radius s/2
  about the centres, so they have disjoint interiors. This is a packing of congruent balls; any packing
  has this form.
- **`finiteDensity S R`** is vol(balls ∩ B(0,R)) / vol(B(0,R)), in `ℝ≥0∞`.
- **`density S`** is the `limsup` of `finiteDensity S R` as R → ∞. This is the upper density, the
  standard definition (Cohn, Notices AMS 2017).
- **`SpherePackingConstant d`** is `⨆ S : SpherePacking d, S.density`, the supremum over *all* packings,
  periodic or not. The theorem is therefore the full sphere packing problem, not the lattice or periodic
  version.
- **`E8Packing`** has separation √2 and centre set `E8Lattice`. That is the image of `Submodule.E8`:
  vectors whose coordinates are all integers or all halves of odd integers, with even coordinate sum.
  This is the usual description of E₈ (D₈⁺).
- **`LeechPacking`** has separation 2 and centre set the ℤ-span of the 24 rows of
  `leechGeneratorMatrixInt` divided by √8. This is the standard generator matrix of Conway and Sloane
  (*Sphere Packings, Lattices and Groups*, Chapter 4).
- **`IsometricToScaledLeech S`** says that there are c > 0 and an isometry of ℝ²⁴ that carries the centres
  of S onto those of the Leech packing scaled by c, with the same separation. This is a genuine
  uniqueness statement among periodic packings, as in Cohn–Kumar–Miller–Radchenko–Viazovska.

The lattices are checked independently of Lean, from the matrices in the Lean source (`data/` is
extracted from it, and `extract_lattices.py --check` confirms they match):

| Check | E₈ | Leech |
|---|---|---|
| Gram matrix integral with even diagonal (Python, Julia, exact) | yes | yes |
| det(Gram) = 1, covolume 1 (Python, Julia, exact) | yes | yes |
| Vectors of norm 2 (C box search for E₈; C++ LLL + Fincke–Pohst, exact norms) | 240 | 0 |
| Vectors of norm 4 | 2160 | 196560 |
| Density vol(B(s/2)) / covolume (Python; Julia to 70 digits) | π⁴/384 | π¹²/12! |

The E₈ generators lie in D₈⁺ and span a sublattice of determinant 1. Since D₈⁺ is unimodular, they span
all of it.

The Leech generators span an even unimodular lattice of rank 24 with no vectors of norm 2. By Conway's
theorem that lattice is the Leech lattice, and its 196560 minimal vectors confirm this.

So `E8Packing` and `LeechPacking` are the packings of the theorems, and the densities in the Lean
statements are the right numbers.

## 4. Findings

No mistake was found, in the formal statements, in the build or in the checks above.

Two corrections to the source papers were found by the upstream project during formalization, not here:
- a sign error in Proposition 7 of Viazovska's dimension-8 paper, and the corrected expression for the
  magic function g;
- an incomplete step in the computer-assisted Appendix A of the dimension-24 paper.

They are recorded in `sphere-packing/README.md`. Both are fixed in the formal proof.

## 5. CI results

Run 38093757203 of `.github/workflows/lean.yml` on commit `bf86a35` (pull request #3), 10 October 2026,
23:04–23:48 UTC. Both jobs passed.

| Step | Result |
|---|---|
| `lake build` | "Build completed successfully (4561 jobs)", no `sorry` warning |
| `#print axioms`, `verification/Statements.lean` | 7 theorems, each depending only on `propext`, `Classical.choice`, `Quot.sound` |
| `#print axioms`, upstream `check_axioms.lean` | `SpherePacking.Dim8.MainTheorem` and `SpherePacking.Dim24.MainTheorem`, the same three axioms |
| `verification/Definitions.lean` | prints the definitions of section 3, as read there |
| `leanchecker` kernel replay | 828 of 828 modules `ok`, none failed |
| `verification/run_all.sh` | scan clean (829 Lean files, 180,649 lines); `data/` matches the source; Python and Julia lattice checks pass; E₈: 240 roots and 2160 vectors of norm 4 (C and C++); Leech: no vector of norm 2 and 196560 of norm 4 (C++) |

The seven theorems of `Statements.lean` are `sphere_packing_dim8`, `sphere_packing_dim24`,
`leech_unique_among_periodic`, `SpherePacking.Dim8.MainTheorem`, `SpherePacking.Dim24.MainTheorem`,
`E8Packing_density` and `SpherePacking.Dim24.LeechPacking_density`. The logs are kept as the artifacts
`lean-logs` and `check-logs` of that run.
