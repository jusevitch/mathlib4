/-
Copyright (c) 2021 Jakob Scholbach. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jakob Scholbach
-/
import Mathlib.Algebra.CharP.Basic
import Mathlib.Algebra.CharP.Algebra
import Mathlib.Data.Nat.Prime.Defs

/-!
# Exponential characteristic

This file defines the exponential characteristic, which is defined to be 1 for a ring with
characteristic 0 and the same as the ordinary characteristic, if the ordinary characteristic is
prime. This concept is useful to simplify some theorem statements.
This file establishes a few basic results relating it to the (ordinary characteristic).
The definition is stated for a semiring, but the actual results are for nontrivial rings
(as far as exponential characteristic one is concerned), respectively a ring without zero-divisors
(for prime characteristic).

## Main results
- `ExpChar`: the definition of exponential characteristic
- `expChar_is_prime_or_one`: the exponential characteristic is a prime or one
- `char_eq_expChar_iff`: the characteristic equals the exponential characteristic iff the
  characteristic is prime

## Tags
exponential characteristic, characteristic
-/


universe u

variable (R : Type u)

section Semiring

variable [Semiring R]

/-- The definition of the exponential characteristic of a semiring. -/
class inductive ExpChar (R : Type u) [Semiring R] : ℕ → Prop
  | zero [CharZero R] : ExpChar R 1
  | prime {q : ℕ} (hprime : q.Prime) [hchar : CharP R q] : ExpChar R q

instance expChar_prime (p) [CharP R p] [Fact p.Prime] : ExpChar R p := ExpChar.prime Fact.out
instance expChar_zero [CharZero R] : ExpChar R 1 := ExpChar.zero

instance (S : Type*) [Semiring S] (p) [ExpChar R p] [ExpChar S p] : ExpChar (R × S) p := by
  obtain hp | ⟨hp⟩ := ‹ExpChar R p›
  · have := Prod.charZero_of_left R S; exact .zero
  obtain _ | _ := ‹ExpChar S p›
  · exact (Nat.not_prime_one hp).elim
  · have := Prod.charP R S p; exact .prime hp

variable {R} in
/-- The exponential characteristic is unique. -/
theorem ExpChar.eq {p q : ℕ} (hp : ExpChar R p) (hq : ExpChar R q) : p = q := by
  rcases hp with ⟨hp⟩ | ⟨hp'⟩
  · rcases hq with hq | hq'
    exacts [rfl, False.elim (Nat.not_prime_zero (CharP.eq R ‹_› (CharP.ofCharZero R) ▸ hq'))]
  · rcases hq with hq | hq'
    exacts [False.elim (Nat.not_prime_zero (CharP.eq R ‹_› (CharP.ofCharZero R) ▸ hp')),
      CharP.eq R ‹_› ‹_›]

theorem ExpChar.congr {p : ℕ} (q : ℕ) [hq : ExpChar R q] (h : q = p) : ExpChar R p := h ▸ hq

/-- Noncomputable function that outputs the unique exponential characteristic of a semiring. -/
noncomputable def ringExpChar (R : Type*) [NonAssocSemiring R] : ℕ := max (ringChar R) 1

theorem ringExpChar.eq (q : ℕ) [h : ExpChar R q] : ringExpChar R = q := by
  rcases h with _ | h
  · haveI := CharP.ofCharZero R
    rw [ringExpChar, ringChar.eq R 0]; rfl
  rw [ringExpChar, ringChar.eq R q]
  exact Nat.max_eq_left h.one_lt.le

@[simp]
theorem ringExpChar.eq_one (R : Type*) [NonAssocSemiring R] [CharZero R] : ringExpChar R = 1 := by
  rw [ringExpChar, ringChar.eq_zero, max_eq_right zero_le_one]

/-- The exponential characteristic is one if the characteristic is zero. -/
theorem expChar_one_of_char_zero (q : ℕ) [hp : CharP R 0] [hq : ExpChar R q] : q = 1 := by
  rcases hq with q | hq_prime
  · rfl
  · exact False.elim <| hq_prime.ne_zero <| ‹CharP R q›.eq R hp

/-- The characteristic equals the exponential characteristic iff the former is prime. -/
theorem char_eq_expChar_iff (p q : ℕ) [hp : CharP R p] [hq : ExpChar R q] : p = q ↔ p.Prime := by
  rcases hq with q | hq_prime
  · rw [(CharP.eq R hp inferInstance : p = 0)]
    decide
  · exact ⟨fun hpq => hpq.symm ▸ hq_prime, fun _ => CharP.eq R hp ‹CharP R q›⟩

/-- The exponential characteristic is a prime number or one.
See also `CharP.char_is_prime_or_zero`. -/
theorem expChar_is_prime_or_one (q : ℕ) [hq : ExpChar R q] : Nat.Prime q ∨ q = 1 := by
  cases hq with
  | zero => exact .inr rfl
  | prime hp => exact .inl hp

/-- The exponential characteristic is positive. -/
theorem expChar_pos (q : ℕ) [ExpChar R q] : 0 < q := by
  rcases expChar_is_prime_or_one R q with h | rfl
  exacts [Nat.Prime.pos h, Nat.one_pos]

/-- Any power of the exponential characteristic is positive. -/
theorem expChar_pow_pos (q : ℕ) [ExpChar R q] (n : ℕ) : 0 < q ^ n :=
  Nat.pos_pow_of_pos n (expChar_pos R q)

section Nontrivial

variable [Nontrivial R]

/-- The exponential characteristic is one if the characteristic is zero. -/
theorem char_zero_of_expChar_one (p : ℕ) [hp : CharP R p] [hq : ExpChar R 1] : p = 0 := by
  cases hq
  · exact CharP.eq R hp inferInstance
  · exact False.elim (CharP.char_ne_one R 1 rfl)

-- This could be an instance, but there are no `ExpChar R 1` instances in mathlib.
/-- The characteristic is zero if the exponential characteristic is one. -/
theorem charZero_of_expChar_one' [hq : ExpChar R 1] : CharZero R := by
  cases hq
  · assumption
  · exact False.elim (CharP.char_ne_one R 1 rfl)

/-- The exponential characteristic is one iff the characteristic is zero. -/
theorem expChar_one_iff_char_zero (p q : ℕ) [CharP R p] [ExpChar R q] : q = 1 ↔ p = 0 := by
  constructor
  · rintro rfl
    exact char_zero_of_expChar_one R p
  · rintro rfl
    exact expChar_one_of_char_zero R q

section NoZeroDivisors

variable [NoZeroDivisors R]

/-- A helper lemma: the characteristic is prime if it is non-zero. -/
theorem char_prime_of_ne_zero {p : ℕ} [hp : CharP R p] (p_ne_zero : p ≠ 0) : Nat.Prime p := by
  rcases CharP.char_is_prime_or_zero R p with h | h
  · exact h
  · contradiction

end NoZeroDivisors

end Nontrivial

end Semiring

theorem ExpChar.exists [Ring R] [IsDomain R] : ∃ q, ExpChar R q := by
  obtain _ | ⟨p, ⟨hp⟩, _⟩ := CharP.exists' R
  exacts [⟨1, .zero⟩, ⟨p, .prime hp⟩]

theorem ExpChar.exists_unique [Ring R] [IsDomain R] : ∃! q, ExpChar R q :=
  let ⟨q, H⟩ := ExpChar.exists R
  ⟨q, H, fun _ H2 ↦ ExpChar.eq H2 H⟩

instance ringExpChar.expChar [Ring R] [IsDomain R] : ExpChar R (ringExpChar R) := by
  obtain ⟨q, _⟩ := ExpChar.exists R
  rwa [ringExpChar.eq R q]

variable {R} in
theorem ringExpChar.of_eq [Ring R] [IsDomain R] {q : ℕ} (h : ringExpChar R = q) : ExpChar R q :=
  h ▸ ringExpChar.expChar R

variable {R} in
theorem ringExpChar.eq_iff [Ring R] [IsDomain R] {q : ℕ} : ringExpChar R = q ↔ ExpChar R q :=
  ⟨ringExpChar.of_eq, fun _ ↦ ringExpChar.eq R q⟩

/-- If a ring homomorphism `R →+* A` is injective then `A` has the same exponential characteristic
as `R`. -/
theorem expChar_of_injective_ringHom {R A : Type*}
    [Semiring R] [Semiring A] {f : R →+* A} (h : Function.Injective f)
    (q : ℕ) [hR : ExpChar R q] : ExpChar A q := by
  rcases hR with _ | hprime
  · haveI := charZero_of_injective_ringHom h; exact .zero
  haveI := charP_of_injective_ringHom h q; exact .prime hprime

/-- If `R →+* A` is injective, and `A` is of exponential characteristic `p`, then `R` is also of
exponential characteristic `p`. Similar to `RingHom.charZero`. -/
theorem RingHom.expChar {R A : Type*} [Semiring R] [Semiring A] (f : R →+* A)
    (H : Function.Injective f) (p : ℕ) [ExpChar A p] : ExpChar R p := by
  cases ‹ExpChar A p› with
  | zero => haveI := f.charZero; exact .zero
  | prime hp => haveI := f.charP H p; exact .prime hp

/-- If `R →+* A` is injective, then `R` is of exponential characteristic `p` if and only if `A` is
also of exponential characteristic `p`. Similar to `RingHom.charZero_iff`. -/
theorem RingHom.expChar_iff {R A : Type*} [Semiring R] [Semiring A] (f : R →+* A)
    (H : Function.Injective f) (p : ℕ) : ExpChar R p ↔ ExpChar A p :=
  ⟨fun _ ↦ expChar_of_injective_ringHom H p, fun _ ↦ f.expChar H p⟩

/-- If the algebra map `R →+* A` is injective then `A` has the same exponential characteristic
as `R`. -/
theorem expChar_of_injective_algebraMap {R A : Type*}
    [CommSemiring R] [Semiring A] [Algebra R A] (h : Function.Injective (algebraMap R A))
    (q : ℕ) [ExpChar R q] : ExpChar A q := expChar_of_injective_ringHom h q

theorem add_pow_expChar_of_commute [Semiring R] {q : ℕ} [hR : ExpChar R q]
    (x y : R) (h : Commute x y) : (x + y) ^ q = x ^ q + y ^ q := by
  rcases hR with _ | hprime
  · simp only [pow_one]
  haveI := Fact.mk hprime; exact add_pow_char_of_commute R x y h

theorem add_pow_expChar_pow_of_commute [Semiring R] {q : ℕ} [hR : ExpChar R q]
    {n : ℕ} (x y : R) (h : Commute x y) : (x + y) ^ q ^ n = x ^ q ^ n + y ^ q ^ n := by
  rcases hR with _ | hprime
  · simp only [one_pow, pow_one]
  haveI := Fact.mk hprime; exact add_pow_char_pow_of_commute R x y n h

theorem sub_pow_expChar_of_commute [Ring R] {q : ℕ} [hR : ExpChar R q]
    (x y : R) (h : Commute x y) : (x - y) ^ q = x ^ q - y ^ q := by
  rcases hR with _ | hprime
  · simp only [pow_one]
  haveI := Fact.mk hprime; exact sub_pow_char_of_commute R x y h

theorem sub_pow_expChar_pow_of_commute [Ring R] {q : ℕ} [hR : ExpChar R q]
    {n : ℕ} (x y : R) (h : Commute x y) : (x - y) ^ q ^ n = x ^ q ^ n - y ^ q ^ n := by
  rcases hR with _ | hprime
  · simp only [one_pow, pow_one]
  haveI := Fact.mk hprime; exact sub_pow_char_pow_of_commute R x y n h

theorem add_pow_expChar [CommSemiring R] {q : ℕ} [hR : ExpChar R q]
    (x y : R) : (x + y) ^ q = x ^ q + y ^ q := by
  rcases hR with _ | hprime
  · simp only [pow_one]
  haveI := Fact.mk hprime; exact add_pow_char R x y

theorem add_pow_expChar_pow [CommSemiring R] {q : ℕ} [hR : ExpChar R q]
    {n : ℕ} (x y : R) : (x + y) ^ q ^ n = x ^ q ^ n + y ^ q ^ n := by
  rcases hR with _ | hprime
  · simp only [one_pow, pow_one]
  haveI := Fact.mk hprime; exact add_pow_char_pow R x y n

theorem sub_pow_expChar [CommRing R] {q : ℕ} [hR : ExpChar R q]
    (x y : R) : (x - y) ^ q = x ^ q - y ^ q := by
  rcases hR with _ | hprime
  · simp only [pow_one]
  haveI := Fact.mk hprime; exact sub_pow_char R x y

theorem sub_pow_expChar_pow [CommRing R] {q : ℕ} [hR : ExpChar R q]
    {n : ℕ} (x y : R) : (x - y) ^ q ^ n = x ^ q ^ n - y ^ q ^ n := by
  rcases hR with _ | hprime
  · simp only [one_pow, pow_one]
  haveI := Fact.mk hprime; exact sub_pow_char_pow R x y n

theorem ExpChar.neg_one_pow_expChar [Ring R] (q : ℕ) [hR : ExpChar R q] :
    (-1 : R) ^ q = -1 := by
  rcases hR with _ | hprime
  · simp only [pow_one]
  haveI := Fact.mk hprime; exact CharP.neg_one_pow_char R q

theorem ExpChar.neg_one_pow_expChar_pow [Ring R] (q n : ℕ) [hR : ExpChar R q] :
    (-1 : R) ^ q ^ n = -1 := by
  rcases hR with _ | hprime
  · simp only [one_pow, pow_one]
  haveI := Fact.mk hprime; exact CharP.neg_one_pow_char_pow R n q

section frobenius

section CommSemiring

variable [CommSemiring R] {S : Type*} [CommSemiring S] (f : R →* S) (g : R →+* S) (p m n : ℕ)
  [ExpChar R p] [ExpChar S p] (x y : R)

/-- The frobenius map that sends x to x^p -/
def frobenius : R →+* R where
  __ := powMonoidHom p
  map_zero' := zero_pow (expChar_pos R p).ne'
  map_add' := add_pow_expChar R

/-- The iterated frobenius map sending x to x^p^n -/
def iterateFrobenius : R →+* R where
  __ := powMonoidHom (p ^ n)
  map_zero' := zero_pow (expChar_pow_pos R p n).ne'
  map_add' := add_pow_expChar_pow R

variable {R}

theorem frobenius_def : frobenius R p x = x ^ p := rfl

theorem iterateFrobenius_def : iterateFrobenius R p n x = x ^ p ^ n := rfl

theorem iterate_frobenius : (frobenius R p)^[n] x = x ^ p ^ n := congr_fun (pow_iterate p n) x

variable (R)

theorem coe_iterateFrobenius : iterateFrobenius R p n = (frobenius R p)^[n] :=
  (pow_iterate p n).symm

theorem iterateFrobenius_one_apply : iterateFrobenius R p 1 x = x ^ p := by
  rw [iterateFrobenius_def, pow_one]

@[simp]
theorem iterateFrobenius_one : iterateFrobenius R p 1 = frobenius R p :=
  RingHom.ext (iterateFrobenius_one_apply R p)

theorem iterateFrobenius_zero_apply : iterateFrobenius R p 0 x = x := by
  rw [iterateFrobenius_def, pow_zero, pow_one]

@[simp]
theorem iterateFrobenius_zero : iterateFrobenius R p 0 = RingHom.id R :=
  RingHom.ext (iterateFrobenius_zero_apply R p)

theorem iterateFrobenius_add_apply :
    iterateFrobenius R p (m + n) x = iterateFrobenius R p m (iterateFrobenius R p n x) := by
  simp_rw [iterateFrobenius_def, add_comm m n, pow_add, pow_mul]

theorem iterateFrobenius_add :
    iterateFrobenius R p (m + n) = (iterateFrobenius R p m).comp (iterateFrobenius R p n) :=
  RingHom.ext (iterateFrobenius_add_apply R p m n)

theorem iterateFrobenius_mul_apply :
    iterateFrobenius R p (m * n) x = (iterateFrobenius R p m)^[n] x := by
  simp_rw [coe_iterateFrobenius, Function.iterate_mul]

theorem coe_iterateFrobenius_mul : iterateFrobenius R p (m * n) = (iterateFrobenius R p m)^[n] :=
  funext (iterateFrobenius_mul_apply R p m n)

variable {R}

theorem frobenius_mul : frobenius R p (x * y) = frobenius R p x * frobenius R p y :=
  map_mul (frobenius R p) x y

theorem frobenius_one : frobenius R p 1 = 1 :=
  one_pow _

theorem MonoidHom.map_frobenius : f (frobenius R p x) = frobenius S p (f x) :=
  map_pow f x p

theorem RingHom.map_frobenius : g (frobenius R p x) = frobenius S p (g x) :=
  map_pow g x p

theorem MonoidHom.map_iterate_frobenius (n : ℕ) :
    f ((frobenius R p)^[n] x) = (frobenius S p)^[n] (f x) :=
  Function.Semiconj.iterate_right (f.map_frobenius p) n x

theorem RingHom.map_iterate_frobenius (n : ℕ) :
    g ((frobenius R p)^[n] x) = (frobenius S p)^[n] (g x) :=
  g.toMonoidHom.map_iterate_frobenius p x n

theorem MonoidHom.iterate_map_frobenius (f : R →* R) (p : ℕ) [ExpChar R p] (n : ℕ) :
    f^[n] (frobenius R p x) = frobenius R p (f^[n] x) :=
  iterate_map_pow f _ _ _

theorem RingHom.iterate_map_frobenius (f : R →+* R) (p : ℕ) [ExpChar R p] (n : ℕ) :
    f^[n] (frobenius R p x) = frobenius R p (f^[n] x) :=
  iterate_map_pow f _ _ _

variable (R S)

/-- The frobenius map of an algebra as a frobenius-semilinear map. -/
nonrec def LinearMap.frobenius [Algebra R S] : S →ₛₗ[frobenius R p] S where
  __ := frobenius S p
  map_smul' r s := show frobenius S p _ = _ by
    simp_rw [Algebra.smul_def, map_mul, ← (algebraMap R S).map_frobenius]; rfl

/-- The iterated frobenius map of an algebra as a iterated-frobenius-semilinear map. -/
nonrec def LinearMap.iterateFrobenius [Algebra R S] : S →ₛₗ[iterateFrobenius R p n] S where
  __ := iterateFrobenius S p n
  map_smul' f s := show iterateFrobenius S p n _ = _ by
    simp_rw [iterateFrobenius_def, Algebra.smul_def, mul_pow, ← map_pow]; rfl

theorem LinearMap.frobenius_def [Algebra R S] (x : S) : frobenius R S p x = x ^ p := rfl

theorem LinearMap.iterateFrobenius_def [Algebra R S] (n : ℕ) (x : S) :
    iterateFrobenius R S p n x = x ^ p ^ n := rfl

theorem frobenius_zero : frobenius R p 0 = 0 :=
  (frobenius R p).map_zero

theorem frobenius_add : frobenius R p (x + y) = frobenius R p x + frobenius R p y :=
  (frobenius R p).map_add x y

theorem frobenius_natCast (n : ℕ) : frobenius R p n = n :=
  map_natCast (frobenius R p) n

@[deprecated (since := "2024-04-17")]
alias frobenius_nat_cast := frobenius_natCast

variable {R}

theorem list_sum_pow_char (l : List R) : l.sum ^ p = (l.map (· ^ p : R → R)).sum :=
  map_list_sum (frobenius R p) _

theorem multiset_sum_pow_char (s : Multiset R) : s.sum ^ p = (s.map (· ^ p : R → R)).sum :=
  map_multiset_sum (frobenius R p) _

theorem sum_pow_char {ι : Type*} (s : Finset ι) (f : ι → R) :
    (∑ i ∈ s, f i) ^ p = ∑ i ∈ s, f i ^ p :=
  map_sum (frobenius R p) _ _

variable (n : ℕ)

theorem list_sum_pow_char_pow (l : List R) : l.sum ^ p ^ n = (l.map (· ^ p ^ n : R → R)).sum :=
  map_list_sum (iterateFrobenius R p n) _

theorem multiset_sum_pow_char_pow (s : Multiset R) :
    s.sum ^ p ^ n = (s.map (· ^ p ^ n : R → R)).sum :=
  map_multiset_sum (iterateFrobenius R p n) _

theorem sum_pow_char_pow {ι : Type*} (s : Finset ι) (f : ι → R) :
    (∑ i ∈ s, f i) ^ p ^ n = ∑ i ∈ s, f i ^ p ^ n :=
  map_sum (iterateFrobenius R p n) _ _

end CommSemiring

section CommRing

variable [CommRing R] (p : ℕ) [ExpChar R p] (x y : R)

theorem frobenius_neg : frobenius R p (-x) = -frobenius R p x :=
  map_neg ..

theorem frobenius_sub : frobenius R p (x - y) = frobenius R p x - frobenius R p y :=
  map_sub ..

end CommRing

end frobenius
