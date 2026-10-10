# The Kepler conjecture (dimension 3) in proof assistants, as of 10 October 2026

**There is no complete formal proof of the Kepler conjecture in Lean.** The only complete formal proof
is the Flyspeck project, in HOL Light and Isabelle.

## Flyspeck

- Hales's proof (Ann. of Math. 162 (2005), 1065–1185) was formalized by the Flyspeck project, completed on
  10 August 2014: T. Hales et al., *A formal proof of the Kepler conjecture*, Forum Math. Pi 5 (2017), e2,
  doi:10.1017/fmp.2017.1 (arXiv:1501.02155).
- It combines HOL Light (the text parts, the linear programs and the nonlinear inequalities) and
  Isabelle (the classification of tame graphs). About 500,000 lines of proof scripts.
- Hales reviewed the project in *The formal proof of the Kepler conjecture: a critical retrospective*
  (arXiv:2402.08032, 2024).
- Re-running Flyspeck needs HOL Light with OCaml and many processor-days for the nonlinear inequalities.
  That is outside what this repository can run in CI.

## Lean

- [lispc/kepler-conjecture-lean4](https://github.com/lispc/kepler-conjecture-lean4) is a Lean 4 port in
  progress (Lean v4.32.2). Its README, dated 10 October 2026, reports:
  - nonlinear inequalities: 68 of 176 cases closed in the solver layer, 8 closed in the kernel;
  - text proofs still being filled in;
  - three "frozen interface" `sorry`s in the end-to-end theorem `Kepler.the_kepler_conjecture_e2e`;
  - 624 shard axioms from `native_decide` admitted by a stated exception.
- The repository is larger than the free disk of this session, so it was read on GitHub, not cloned or
  built.
- So no Lean proof of the Kepler conjecture can be checked here today.
- Terence Tao wrote on 9 October 2026 that a soundness bug in Lean's kernel, found this summer and since
  fixed, produced a short *illicit* Lean proof of the Kepler conjecture. That is a reason to accept a
  future Lean proof only after the checks used for dimensions 8 and 24 in this repository: a kernel
  replay, an axiom audit and a statement audit.

## What this repository can add

When the Lean port is complete, the same checks as for dimensions 8 and 24 apply:
- the build;
- `#print axioms` on the main theorem (no `sorry`, no extra axioms; the `native_decide` shards would have to
  be removed or replayed with `decide +kernel`);
- `leanchecker`;
- a check that the statement says sup density = π/√18 for packings of congruent balls in ℝ³.
