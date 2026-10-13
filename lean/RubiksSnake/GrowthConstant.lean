import RubiksSnake.SnAsymptotic.FinalResults
import RubiksSnake.SnAsymptotic.Submultiplicativity
import Mathlib.Analysis.Asymptotics.Theta
import Mathlib.Analysis.SpecialFunctions.Pow.Continuity

/-! Definition and statements about Rubik's Snake growth constant:

 - We know that there is a specific real constant associated with Rubik's
    Snake. We call it RSGS (Rubiks Snake Growth Constant).
 - We know that 3.4505674 ≤ RSGS ≤ 3.661786723, where bounds are transferred
    from pointwise bounds.
 - We know that S(n)=p(n)*RSGS^n for some subexponential p.
-/

open Asymptotics Filter Topology

namespace RubiksSnake

noncomputable section

/-- Rubiks Snake Growth Constant - the exponential growth constant of the
number of valid Rubik's Snake formulas. -/
def RSGS : ℝ :=
  Real.exp logValidFormulaCount_subadditive.lim

/-- Limit of S(n-1)^(1/n) exists and is equal to the growth constant. -/
theorem limitExists1 :
    Tendsto
      (fun n : ℕ => (countValidFormulas n : ℝ) ^ (1 / (n : ℝ)))
      atTop (𝓝 RSGS) := by
  have hlog :=
    logValidFormulaCount_subadditive.tendsto_lim
      logValidFormulaCount_div_bddBelow
  have hexp :=
    (Real.continuous_exp.tendsto logValidFormulaCount_subadditive.lim).comp hlog
  convert hexp using 1
  · funext n
    rw [Real.rpow_def_of_pos]
    · simp [logValidFormulaCount, div_eq_mul_inv]
    · exact_mod_cast countValidFormulas_pos n
  · rfl

/-- Limit of S_n^(1/n) exists and is equal to the growth constant. -/
theorem limitExists2 :
    Tendsto
      (fun n : ℕ+ => (S n : ℝ) ^ (1 / (n : ℝ)))
      atTop (𝓝 RSGS) := by
  change Tendsto
    (fun n : ℕ+ => (countValidFormulas (n.val - 1) : ℝ) ^ (1 / (n.val : ℝ)))
    atTop (𝓝 RSGS)
  apply (PNat.tendsto_comp_val_iff
    (f := fun n : ℕ => (countValidFormulas (n - 1) : ℝ) ^ (1 / (n : ℝ)))).mpr
  simpa using
    ((limitExists1.comp (tendsto_sub_atTop_nat 1)).rpow
      ((tendsto_natCast_div_add_atTop (1 : ℝ)).comp (tendsto_sub_atTop_nat 1))
      (Or.inl (Real.exp_ne_zero _))).congr' (by
      filter_upwards [eventually_ge_atTop 2] with n hn
      have hsub : ((n - 1 : ℕ) : ℝ) ≠ 0 := by
        exact_mod_cast (show n - 1 ≠ 0 by omega)
      simp only [Function.comp_apply]
      rw [← Real.rpow_mul
        (show 0 ≤ (countValidFormulas (n - 1) : ℝ) by positivity)]
      rw [show ((n - 1 : ℕ) : ℝ) + 1 = (n : ℝ) by
        exact_mod_cast (show n - 1 + 1 = n by omega)]
      congr 1
      all_goals field_simp [hsub])

/-- Transfers pointwise lower bound on S_n to lower bound on RSGS. -/
lemma transferLowerBound(a: ℝ):
    (∀ n : ℕ+, a ^ ((n : ℕ) - 1) ≤ (S n : ℝ)) → a ≤ RSGS := by
  intro h
  by_cases ha : 0 ≤ a
  · apply ge_of_tendsto limitExists1
    filter_upwards [eventually_ge_atTop 1] with n hn
    simp only [one_div]
    rw [← Real.pow_rpow_inv_natCast ha (by omega : n ≠ 0)]
    apply Real.rpow_le_rpow (pow_nonneg ha n)
    · simpa [S] using h n.succPNat
    · positivity
  · exact (le_of_not_ge ha).trans (Real.exp_pos _).le

/-- Lower bound on RSGS. -/
lemma RSGS_lowerBound : (3.4505674 : ℝ) ≤ RSGS := by
  exact (transferLowerBound 3.4505674) FinalResults.Sn_lower_bound

/-- Transfers pointwise upper bound on S_n to upper bound on RSGS. -/
lemma transferUpperBound(a C: ℝ):
    (∀ n : ℕ+, (S n : ℝ) ≤ C * a ^ ((n : ℕ) - 1)) → RSGS ≤ a := by
  intro h
  have hC : 0 < C := by
    apply lt_of_lt_of_le (show (0 : ℝ) < S 1 by
      exact_mod_cast countValidFormulas_pos 0)
    simpa [S] using h 1
  have ha : 0 < a := by
    have hCa : 0 < C * a := by
      apply lt_of_lt_of_le (show (0 : ℝ) < S 2 by
        exact_mod_cast countValidFormulas_pos 1)
      simpa [S] using h 2
    exact pos_of_mul_pos_right hCa hC.le
  have hCrpow :
      Tendsto (fun n : ℕ => C ^ (1 / (n : ℝ))) atTop (𝓝 1) := by
    simpa using tendsto_const_nhds.rpow
      (tendsto_one_div_atTop_nhds_zero_nat (𝕜 := ℝ)) (Or.inl hC.ne')
  have hupper :
      Tendsto (fun n : ℕ => (C * a ^ n) ^ (1 / (n : ℝ))) atTop (𝓝 a) := by
    simpa using
      (hCrpow.mul
        (tendsto_const_nhds : Tendsto (fun _ : ℕ => a) atTop (𝓝 a))).congr' (by
          filter_upwards [eventually_ge_atTop 1] with n hn
          simp only [one_div]
          rw [Real.mul_rpow hC.le (pow_nonneg ha.le n),
            Real.pow_rpow_inv_natCast ha.le (by omega : n ≠ 0)])
  apply le_of_tendsto_of_tendsto limitExists1 hupper
  filter_upwards [eventually_ge_atTop 1] with n hn
  apply Real.rpow_le_rpow (by positivity)
  · simpa [S] using h n.succPNat
  · positivity

/-- Upper bound on RSGS. -/
lemma RSGS_upperBound : RSGS ≤ (3.661786723 : ℝ) := by
  exact (transferUpperBound 3.661786723 2.95621) FinalResults.Sn_upper_bound

/-- A prefactor is subexponential when the `n`-th root of its norm tends to one. -/
def IsSubexponentialPrefactor (p : ℕ+ → ℝ) : Prop :=
  Tendsto (fun n : ℕ+ => ‖p n‖ ^ (1 / (n : ℝ))) atTop (𝓝 1)

/-- The valid-snake count is exactly `p n * RSGS^n` for a subexponential prefactor `p`. -/
theorem exists_subexponential_factorization :
    ∃ p : ℕ+ → ℝ, IsSubexponentialPrefactor p ∧
      ∀ n : ℕ+, (S n : ℝ) = p n * RSGS ^ (n : ℝ) := by
  let p : ℕ+ → ℝ := fun n => (S n : ℝ) / RSGS ^ (n : ℝ)
  have hRSGS : 0 < RSGS := Real.exp_pos _
  have hSpos (n : ℕ+) : 0 < (S n : ℝ) := by
    exact_mod_cast countValidFormulas_pos ((n : ℕ) - 1)
  refine ⟨p, ?_, ?_⟩
  · unfold IsSubexponentialPrefactor
    have hquot :
        Tendsto
          (fun n : ℕ+ => (S n : ℝ) ^ (1 / (n : ℝ)) / RSGS)
          atTop (𝓝 1) := by
      simpa [hRSGS.ne'] using limitExists2.div_const RSGS
    apply hquot.congr'
    exact Eventually.of_forall fun n => by
      have hp : 0 < p n :=
        div_pos (hSpos n) (Real.rpow_pos_of_pos hRSGS (n : ℝ))
      simp only [one_div]
      rw [Real.norm_eq_abs, abs_of_pos hp]
      dsimp [p]
      rw [
        Real.div_rpow (hSpos n).le (Real.rpow_pos_of_pos hRSGS _).le,
        Real.rpow_rpow_inv hRSGS.le (by positivity)]
  · intro n
    dsimp [p]
    rw [div_mul_cancel₀]
    exact (Real.rpow_pos_of_pos hRSGS (n : ℝ)).ne'

end

end RubiksSnake
