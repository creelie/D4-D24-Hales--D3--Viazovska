/-
  Prints the definitions that the headline statements depend on, for the statement audit in
  VERIFICATION.md.  Run from `sphere-packing/`:  lake env lean ../verification/Definitions.lean
-/
import SpherePacking.Dim8.MainTheorem
import SpherePacking.Dim24.MainTheorem

set_option pp.proofs false
#print SpherePacking
#print PeriodicSpherePacking
#print SpherePacking.balls
#print SpherePacking.finiteDensity
#print SpherePacking.density
#print SpherePackingConstant
#print Submodule.E8
#print E8Lattice
#print E8Packing
#print SpherePacking.Dim24.LeechLattice
#print SpherePacking.Dim24.LeechPacking
#print SpherePacking.Dim24.IsometricToScaledLeech
#print PeriodicSpherePacking.Isometric
