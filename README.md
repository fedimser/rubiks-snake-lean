# Lean formalization of Rubik's Snake

This repository uses Lean to formalize the geometry and enumeration of
[Rubik's Snake](https://en.wikipedia.org/wiki/Rubik%27s_Snake).

The main formalized result is the lower and upper bound for
`S(n)`, the number of n-wedge snakes (https://oeis.org/A375865):

```
(3.4505674)^(n-1) <= S(n) <= 2.95621 * (3.661786723)^(n-1)
`````

## Repository structure

* [`lean/RubiksSnake/`](lean/RubiksSnake/) - Lean formalization of Rubik's Snake.
  * [`Definitions.lean`](lean/RubiksSnake/Definitions.lean) - definitions of Rubik's Snake geometry and the main sequence `S(n)` (the number of n-wedge snakes).
  * [`Geometry.lean`](lean/RubiksSnake/Geometry.lean) - shared geometric lemmas and a simple collision-free construction.
  * [`ComputeSnakes.lean`](lean/RubiksSnake/ComputeSnakes.lean) - certified enumeration and tactics for checking concrete counts.
  * [`SnAsymptotic/`](lean/RubiksSnake/SnAsymptotic/) - lower- and upper-bound constructions, executable certificate checks, and correctness proofs.
    * [`FinalResults.lean`](lean/RubiksSnake/SnAsymptotic/FinalResults.lean) - the main result: `(3.4505674)^(n-1) <= S(n) <= 2.95621 * (3.661786723)^(n-1)`.
  * [`OtherSequences/`](lean/RubiksSnake/OtherSequences/) - related counts for loops, rotation-restricted snakes, and symmetry orbits.
  * [`Transforms/`](lean/RubiksSnake/Transforms/) - formula, reflection, and reversal transforms.
* [`papers/sn_bounds/paper.pdf`](papers/sn_bounds/paper.pdf) - accompanying article about the lower and upper bounds on \(S_n\).

## How to build

Install [Git](https://git-scm.com/) and
[elan](https://github.com/leanprover/elan), then clone the repository and
download the pinned toolchain, dependencies, and precompiled Mathlib cache:

```bash
git clone https://github.com/fedimser/rubiks-snake-lean.git
cd rubiks-snake-lean/lean
lake exe cache get
```

Then run the full build from the [`lean/`](lean/) directory:

```bash
lake build
```

## Certified computation

[`ComputeSnakes.lean`](lean/RubiksSnake/ComputeSnakes.lean) defines `fastS`, an
executable version of \(S_n\), and proves it agrees with the mathematical
definition. The `compute_snakes` tactic uses native evaluation to prove
concrete values. For counts restricted by a decidable predicate, the module
provides `fastCountValidShapesPred` and `compute_snakes_pred`:

## Main formal results

[`Sn_lower_bound`](lean/RubiksSnake/SnAsymptotic/FinalResults.lean) and
[`Sn_upper_bound`](lean/RubiksSnake/SnAsymptotic/FinalResults.lean), in the
`RubiksSnake.FinalResults` namespace, prove the displayed bounds for every
positive \(n\).

The lower-bound proof uses geometrically separated cap-and-bridge codes and a
checked finite recurrence. The upper-bound proof uses a finite-memory automaton
built from collision prefixes through length 16.
[`paper.pdf`](papers/sn_bounds/paper.pdf) explains the constructions. The Lean
files contain the geometric proofs, finite certificate checks, and argument for
all positive lengths.
