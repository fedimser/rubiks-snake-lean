# Lean formalization of Rubik's Snake

This repository formalizes the geometry and enumeration of Rubik's Snake in
Lean. It counts collision-free configurations of an oriented snake with
distinguished ends, up to translation and proper rotation (but not reflection
or reversal).

For every positive number of wedges \(n\), the main results prove the pointwise
bounds

\[
(3.4505674)^{n-1} \leq S_n
\leq 2.95621(3.661786723)^{n-1}.
\]

The decimal constants in these statements are exact.

## Repository structure

* [`lean/`](lean/) contains the Lean project.
  * [`RubiksSnake.lean`](lean/RubiksSnake.lean) is the library entry point and
    imports the complete formal development.
  * [`RubiksSnake/Definitions.lean`](lean/RubiksSnake/Definitions.lean) defines
    rotation formulas, the lattice model of wedges, collision freedom, and the
    counting sequence \(S_n\).
  * [`RubiksSnake/Geometry.lean`](lean/RubiksSnake/Geometry.lean) proves shared
    geometric lemmas and gives a simple collision-free construction.
  * [`RubiksSnake/ComputeSnakes.lean`](lean/RubiksSnake/ComputeSnakes.lean)
    implements certified enumeration, proves it agrees with \(S_n\), and
    provides tactics for checking concrete counts.
  * [`RubiksSnake/SnAsymptotic/`](lean/RubiksSnake/SnAsymptotic/) contains the
    lower- and upper-bound constructions, executable certificate checks, and
    their correctness proofs.
    [`FinalResults.lean`](lean/RubiksSnake/SnAsymptotic/FinalResults.lean)
    states the main pointwise bounds.
  * [`RubiksSnake/OtherSequences/`](lean/RubiksSnake/OtherSequences/) studies
    related counts, including loops, rotation-restricted snakes, and orbits
    under symmetries.
  * [`RubiksSnake/Transforms/`](lean/RubiksSnake/Transforms/) defines and proves
    properties of formula, reflection, and reversal transforms.
  * [`lakefile.toml`](lean/lakefile.toml) defines the Lean libraries and pins the
    Mathlib dependency.
  * [`lean-toolchain`](lean/lean-toolchain) pins the Lean version, while
    [`lake-manifest.json`](lean/lake-manifest.json) locks dependency revisions.
* [`papers/sn_bounds/`](papers/sn_bounds/) contains the accompanying article
  and its generated assets.
  * [`paper.pdf`](papers/sn_bounds/paper.pdf) is the rendered article describing
    the pointwise bounds.
  * [`paper.tex`](papers/sn_bounds/paper.tex) and
    [`refs.bib`](papers/sn_bounds/refs.bib) are its LaTeX source and
    bibliography.
  * [`bounds_plot.py`](papers/sn_bounds/bounds_plot.py) generates
    [`bounds_plot.png`](papers/sn_bounds/bounds_plot.png).
* [`.github/workflows/lean.yml`](.github/workflows/lean.yml) builds the full
  Lean project in GitHub Actions.
* [`LICENSE`](LICENSE) contains the repository license.

## Initialize the repository

Install [Git](https://git-scm.com/) and
[elan](https://github.com/leanprover/elan), the Lean toolchain manager. Then
clone the repository and download the pinned Lean toolchain, dependencies, and
precompiled Mathlib cache:

```bash
git clone https://github.com/fedimser/rubiks-snake-lean.git
cd rubiks-snake-lean/lean
lake exe cache get
```

The versions in [`lean-toolchain`](lean/lean-toolchain) and
[`lake-manifest.json`](lean/lake-manifest.json) make the setup reproducible.

## Build the Lean project

From the [`lean/`](lean/) directory, build the complete formalization:

```bash
lake build
```

The default target is the [`RubiksSnake`](lean/RubiksSnake.lean) library, whose
entry point imports all project modules, including the native computation
certificates. To build a single module while developing, pass its module name;
for example:

```bash
lake build RubiksSnake.SnAsymptotic.FinalResults
```

The [Lean CI workflow](.github/workflows/lean.yml) performs the full build on
pushes and pull requests to `main`.

## Certified computation

[`ComputeSnakes.lean`](lean/RubiksSnake/ComputeSnakes.lean) defines `fastS`, an
executable version of \(S_n\), and proves that the executable and mathematical
definitions agree. The `compute_snakes` tactic proves concrete values using
native evaluation.

The same module also provides `fastCountValidShapesPred` and the
`compute_snakes_pred` tactic for certified counts restricted by a decidable
predicate. For example:

```lean
import RubiksSnake.OtherSequences.Burnside

open RubiksSnake

example : S_FIX_REV 5 = 13 := by
  compute_snakes_pred
```

## Main formal results

The theorems
[`Sn_lower_bound`](lean/RubiksSnake/SnAsymptotic/FinalResults.lean) and
[`Sn_upper_bound`](lean/RubiksSnake/SnAsymptotic/FinalResults.lean), in the
`RubiksSnake.FinalResults` namespace, establish the displayed bounds for every
positive \(n\).

The lower bound is constructed from geometrically separated cap-and-bridge
codes and a checked finite recurrence. The upper bound uses a finite-memory
automaton built from collision prefixes through length 16. The accompanying
[`paper.pdf`](papers/sn_bounds/paper.pdf) explains both constructions; the Lean
development proves the geometric details, finite certificate checks, and the
passage to all positive lengths.

## Build the paper

With a LaTeX distribution and `latexmk` installed, compile the article from the
repository root:

```bash
latexmk -pdf -cd papers/sn_bounds/paper.tex
```

The plot generator requires Python with NumPy, Matplotlib, and the `oeis`
package:

```bash
python papers/sn_bounds/bounds_plot.py
```
