/-
  The headline results of `sphere-packing/` restated with the densities written out,
  so that the statements can be read without unfolding `E8Packing` or `LeechPacking`.

  Run from `sphere-packing/` after `lake build`:
      lake env lean ../verification/Statements.lean
  Every theorem below must print exactly the three standard axioms
  [propext, Classical.choice, Quot.sound].
-/
import SpherePacking.Dim8.MainTheorem
import SpherePacking.Dim24.MainTheorem

/-- Viazovska (2017): the sphere packing constant of `ℝ⁸` is `π⁴ / 384`,
the density of the `E₈` lattice packing. -/
theorem sphere_packing_dim8 :
    SpherePackingConstant 8 = ENNReal.ofReal Real.pi ^ 4 / 384 :=
  SpherePacking.Dim8.MainTheorem.trans E8Packing_density

/-- Cohn, Kumar, Miller, Radchenko, Viazovska (2017): the sphere packing constant of `ℝ²⁴`
is `π¹² / 12!`, the density of the Leech lattice packing. -/
theorem sphere_packing_dim24 :
    SpherePackingConstant 24 = ENNReal.ofReal Real.pi ^ 12 / (Nat.factorial 12) :=
  SpherePacking.Dim24.SpherePackingConstant_eq_leech_density.trans
    SpherePacking.Dim24.LeechPacking_density

/-- Uniqueness among periodic packings in `ℝ²⁴`: a periodic packing of density `π¹² / 12!`
is isometric to a scaled copy of the Leech packing. -/
theorem leech_unique_among_periodic (S : PeriodicSpherePacking 24)
    (hS : S.density = ENNReal.ofReal Real.pi ^ 12 / (Nat.factorial 12)) :
    SpherePacking.Dim24.IsometricToScaledLeech S :=
  SpherePacking.Dim24.MainTheorem.2 S (hS.trans SpherePacking.Dim24.LeechPacking_density.symm)

#print axioms sphere_packing_dim8
#print axioms sphere_packing_dim24
#print axioms leech_unique_among_periodic
#print axioms SpherePacking.Dim8.MainTheorem
#print axioms SpherePacking.Dim24.MainTheorem
#print axioms E8Packing_density
#print axioms SpherePacking.Dim24.LeechPacking_density
