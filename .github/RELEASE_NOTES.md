The Lean 4 proofs of sphere packing in dimensions 8 and 24 (math-inc/Sphere-Packing-Lean at
1e98fb4, begun by Hariharan and Viazovska at EPFL, arXiv:2604.23468, and completed by Math, Inc.'s
Gauss), unchanged, with an independent check:

- static scan of all 180,649 lines: no sorry, axiom, native_decide or other kernel bypass;
- statement audit: `SpherePackingConstant 8 = π⁴/384` and `SpherePackingConstant 24 = π¹²/12!` are
  about the upper density of arbitrary packings, and the Leech packing is unique among periodic ones;
- CI: Lean build, `#print axioms` of every headline theorem (only `propext`, `Classical.choice`,
  `Quot.sound`), and a `leanchecker` kernel replay of all 828 SpherePacking modules;
- Python, Julia, C and C++ checks that the lattices in the Lean source are E₈ and the Leech lattice;
- `kepler/STATUS.md`: no complete Lean proof of the Kepler conjecture exists; Flyspeck (HOL Light and
  Isabelle) is the only complete formal proof.

See VERIFICATION.md for the results. The formal proofs are their authors' work.
