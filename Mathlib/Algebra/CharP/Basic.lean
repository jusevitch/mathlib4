/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Joey van Langen, Casper Putz
-/
import Mathlib.Algebra.CharP.Defs
import Mathlib.Data.Nat.Multiplicity
import Mathlib.Data.Nat.Choose.Sum

/-!
# Characteristic of semirings
-/

assert_not_exists orderOf

universe u v

open Finset

variable {R : Type*}

namespace Commute

variable [Semiring R] {p : ℕ} (hp : p.Prime) {x y : R}
include hp

protected theorem add_pow_prime_pow_eq (h : Commute x y) (n : ℕ) :
    (x + y) ^ p ^ n =
      x ^ p ^ n + y ^ p ^ n +
        p * ∑ k ∈ Ioo 0 (p ^ n), x ^ k * y ^ (p ^ n - k) * ↑((p ^ n).choose k / p) := by
  trans x ^ p ^ n + y ^ p ^ n + ∑ k ∈ Ioo 0 (p ^ n), x ^ k * y ^ (p ^ n - k) * (p ^ n).choose k
  · simp_rw [h.add_pow, ← Nat.Ico_zero_eq_range, Nat.Ico_succ_right, Icc_eq_cons_Ico (zero_le _),
      Finset.sum_cons, Ico_eq_cons_Ioo (pow_pos hp.pos _), Finset.sum_cons, tsub_self, tsub_zero,
      pow_zero, Nat.choose_zero_right, Nat.choose_self, Nat.cast_one, mul_one, one_mul, ← add_assoc]
  · congr 1
    simp_rw [Finset.mul_sum, Nat.cast_comm, mul_assoc _ _ (p : R), ← Nat.cast_mul]
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [mem_Ioo] at hi
    rw [Nat.div_mul_cancel (hp.dvd_choose_pow hi.1.ne' hi.2.ne)]

protected theorem add_pow_prime_eq (h : Commute x y) :
    (x + y) ^ p =
      x ^ p + y ^ p + p * ∑ k ∈ Finset.Ioo 0 p, x ^ k * y ^ (p - k) * ↑(p.choose k / p) := by
  simpa using h.add_pow_prime_pow_eq hp 1

protected theorem exists_add_pow_prime_pow_eq (h : Commute x y) (n : ℕ) :
    ∃ r, (x + y) ^ p ^ n = x ^ p ^ n + y ^ p ^ n + p * r :=
  ⟨_, h.add_pow_prime_pow_eq hp n⟩

protected theorem exists_add_pow_prime_eq (h : Commute x y) :
    ∃ r, (x + y) ^ p = x ^ p + y ^ p + p * r :=
  ⟨_, h.add_pow_prime_eq hp⟩

end Commute

section CommSemiring

variable [CommSemiring R] {p : ℕ} (hp : p.Prime) (x y : R) (n : ℕ)
include hp

theorem add_pow_prime_pow_eq :
    (x + y) ^ p ^ n =
      x ^ p ^ n + y ^ p ^ n +
        p * ∑ k ∈ Finset.Ioo 0 (p ^ n), x ^ k * y ^ (p ^ n - k) * ↑((p ^ n).choose k / p) :=
  (Commute.all x y).add_pow_prime_pow_eq hp n

theorem add_pow_prime_eq :
    (x + y) ^ p =
      x ^ p + y ^ p + p * ∑ k ∈ Finset.Ioo 0 p, x ^ k * y ^ (p - k) * ↑(p.choose k / p) :=
  (Commute.all x y).add_pow_prime_eq hp

theorem exists_add_pow_prime_pow_eq :
    ∃ r, (x + y) ^ p ^ n = x ^ p ^ n + y ^ p ^ n + p * r :=
  (Commute.all x y).exists_add_pow_prime_pow_eq hp n

theorem exists_add_pow_prime_eq :
    ∃ r, (x + y) ^ p = x ^ p + y ^ p + p * r :=
  (Commute.all x y).exists_add_pow_prime_eq hp

end CommSemiring

variable (R) (x y : R) (n : ℕ)

theorem add_pow_char_of_commute [Semiring R] {p : ℕ} [hp : Fact p.Prime] [CharP R p]
    (h : Commute x y) : (x + y) ^ p = x ^ p + y ^ p := by
  let ⟨r, hr⟩ := h.exists_add_pow_prime_eq hp.out
  simp [hr]

theorem add_pow_char_pow_of_commute [Semiring R] {p : ℕ} [hp : Fact p.Prime] [CharP R p]
    (h : Commute x y) : (x + y) ^ p ^ n = x ^ p ^ n + y ^ p ^ n := by
  let ⟨r, hr⟩ := h.exists_add_pow_prime_pow_eq hp.out n
  simp [hr]

theorem sub_pow_char_of_commute [Ring R] {p : ℕ} [Fact p.Prime] [CharP R p] (h : Commute x y) :
    (x - y) ^ p = x ^ p - y ^ p := by
  rw [eq_sub_iff_add_eq, ← add_pow_char_of_commute _ _ _ (Commute.sub_left h rfl)]
  simp

theorem sub_pow_char_pow_of_commute [Ring R] {p : ℕ} [Fact p.Prime] [CharP R p] (h : Commute x y) :
    (x - y) ^ p ^ n = x ^ p ^ n - y ^ p ^ n := by
  induction n with
  | zero => simp
  | succ n n_ih =>
      rw [pow_succ, pow_mul, pow_mul, pow_mul, n_ih]
      apply sub_pow_char_of_commute; apply Commute.pow_pow h

theorem add_pow_char [CommSemiring R] {p : ℕ} [Fact p.Prime] [CharP R p] :
    (x + y) ^ p = x ^ p + y ^ p :=
  add_pow_char_of_commute _ _ _ (Commute.all _ _)

theorem add_pow_char_pow [CommSemiring R] {p : ℕ} [Fact p.Prime] [CharP R p] :
    (x + y) ^ p ^ n = x ^ p ^ n + y ^ p ^ n :=
  add_pow_char_pow_of_commute _ _ _ _ (Commute.all _ _)

theorem add_pow_eq_add_pow_mod_mul_pow_add_pow_div
    [CommSemiring R] {p : ℕ} [Fact p.Prime] [CharP R p] (x y : R) :
    (x + y) ^ n = (x + y) ^ (n % p) * (x ^ p + y ^ p) ^ (n / p) := by
  rw [← add_pow_char, ← pow_mul, ← pow_add, Nat.mod_add_div]

theorem sub_pow_char [CommRing R] {p : ℕ} [Fact p.Prime] [CharP R p] :
    (x - y) ^ p = x ^ p - y ^ p :=
  sub_pow_char_of_commute _ _ _ (Commute.all _ _)

theorem sub_pow_char_pow [CommRing R] {p : ℕ} [Fact p.Prime] [CharP R p] :
    (x - y) ^ p ^ n = x ^ p ^ n - y ^ p ^ n :=
  sub_pow_char_pow_of_commute _ _ _ _ (Commute.all _ _)

theorem sub_pow_eq_sub_pow_mod_mul_pow_sub_pow_div [CommRing R] {p : ℕ} [Fact p.Prime] [CharP R p] :
    (x - y) ^ n = (x - y) ^ (n % p) * (x ^ p - y ^ p) ^ (n / p) := by
  rw [← sub_pow_char, ← pow_mul, ← pow_add, Nat.mod_add_div]

theorem CharP.neg_one_pow_char [Ring R] (p : ℕ) [Fact p.Prime] [CharP R p] :
    (-1 : R) ^ p = -1 := by
  rw [eq_neg_iff_add_eq_zero]
  nth_rw 2 [← one_pow p]
  rw [← add_pow_char_of_commute R _ _ (Commute.one_right _), neg_add_cancel,
    zero_pow (Fact.out (p := Nat.Prime p)).ne_zero]

theorem CharP.neg_one_pow_char_pow [Ring R] (p : ℕ) [CharP R p] [Fact p.Prime] :
    (-1 : R) ^ p ^ n = -1 := by
  rw [eq_neg_iff_add_eq_zero]
  nth_rw 2 [← one_pow (p ^ n)]
  rw [← add_pow_char_pow_of_commute R _ _ _ (Commute.one_right _), neg_add_cancel,
    zero_pow (pow_ne_zero _ (Fact.out (p := Nat.Prime p)).ne_zero)]

namespace CharP

section

variable [NonAssocRing R]

/-- The characteristic of a finite ring cannot be zero. -/
theorem char_ne_zero_of_finite (p : ℕ) [CharP R p] [Finite R] : p ≠ 0 := by
  rintro rfl
  haveI : CharZero R := charP_to_charZero R
  cases nonempty_fintype R
  exact absurd Nat.cast_injective (not_injective_infinite_finite ((↑) : ℕ → R))

theorem ringChar_ne_zero_of_finite [Finite R] : ringChar R ≠ 0 :=
  char_ne_zero_of_finite R (ringChar R)

end

section Ring

variable [Ring R] [NoZeroDivisors R] [Nontrivial R] [Finite R]

theorem char_is_prime (p : ℕ) [CharP R p] : p.Prime :=
  Or.resolve_right (char_is_prime_or_zero R p) (char_ne_zero_of_finite R p)

end Ring
end CharP
