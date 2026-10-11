# Sphere packing in dimensions 8, 24 and 3: an independent check of the formal proofs

This repository collects the formal proofs of the three solved cases of the sphere packing problem
above dimension 2, checks them independently, and records what is and is not formalized in Lean.
It was set up by Deep Bhattacharjee to look for mistakes in these proofs and to learn from their
formalization. The proofs themselves are the work of the authors credited below.

| Dimension | Optimal packing and density | Proof | Formal proof | Status here |
|---|---|---|---|---|
| 8 | E₈ lattice, π⁴/384 | Viazovska, Ann. of Math. 185 (2017) | Lean 4 + Mathlib, `sphere-packing/` | built in CI, audited |
| 24 | Leech lattice, π¹²/12!, unique among periodic packings | Cohn, Kumar, Miller, Radchenko, Viazovska, Ann. of Math. 185 (2017) | Lean 4 + Mathlib, `sphere-packing/` | built in CI, audited |
| 3 | face-centred cubic, π/√18 (Kepler) | Hales, Ann. of Math. 162 (2005) | HOL Light and Isabelle (Flyspeck, 2014); **no complete Lean proof exists** | see `kepler/STATUS.md` |

(The repository name says D4; the dimension meant is 8.)

## Contents

- `sphere-packing/` is an unchanged copy of
  [math-inc/Sphere-Packing-Lean](https://github.com/math-inc/Sphere-Packing-Lean) at commit `1e98fb4`
  (2 March 2026; Lean v4.28.0, Mathlib v4.28.0; 830 files, about 180,000 lines; Apache-2.0). It descends
  from the dimension-8 project started by Sidharth Hariharan and Maryna Viazovska at EPFL in 2024
  ([thefundamentaltheor3m/Sphere-Packing-Lean](https://github.com/thefundamentaltheor3m/Sphere-Packing-Lean);
  Hariharan, Birkbeck, Lee, Ma, Mehta, Poiroux, Viazovska, arXiv:2604.23468), completed in dimension 8
  and extended to dimension 24 by Math, Inc.'s autoformalization agent Gauss. Its own README is
  `sphere-packing/README.md`.
- `verification/` holds the checks added here; `VERIFICATION.md` describes them and the results.
- `kepler/STATUS.md` records the state of the Kepler conjecture in proof assistants.

## The theorems

`verification/Statements.lean` restates the main results with the densities written out:

```lean
theorem sphere_packing_dim8 :
    SpherePackingConstant 8 = ENNReal.ofReal Real.pi ^ 4 / 384
theorem sphere_packing_dim24 :
    SpherePackingConstant 24 = ENNReal.ofReal Real.pi ^ 12 / (Nat.factorial 12)
theorem leech_unique_among_periodic (S : PeriodicSpherePacking 24)
    (hS : S.density = ENNReal.ofReal Real.pi ^ 12 / (Nat.factorial 12)) :
    SpherePacking.Dim24.IsometricToScaledLeech S
```

Here `SpherePackingConstant d` is the supremum, over all packings of congruent balls in ℝᵈ, of the upper
density (the `limsup` as R → ∞ of the fraction of the ball of radius R about the origin that the balls
cover). `VERIFICATION.md` goes through each definition.

## Archive

Release v1.0.0 is archived on Zenodo as
[10.5281/zenodo.23289869](https://doi.org/10.5281/zenodo.23289869); every version is under
[10.5281/zenodo.23289868](https://doi.org/10.5281/zenodo.23289868). The creators are the authors of the
formal proofs; Deep Bhattacharjee is listed as data curator.

## Licenses

`sphere-packing/` keeps its Apache-2.0 license (`sphere-packing/LICENSE`). The files added in this
repository are under the MIT license in `LICENSE`.
