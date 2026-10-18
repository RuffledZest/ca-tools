# DCAN notes, 2026-09-12

Source read by eye from the publisher pdf (no copy made, and the pdf is
not in this repository): Jianxing Yin, "Constructions of difference covering
arrays", Journal of Combinatorial Theory, Series A 104 (2003) 327-339,
doi 10.1016/j.jcta.2003.09.005. Statements below are transcribed from
the page images; notation: C_q the cyclic group of order q, EA(q) the
additive group of GF(q), a (q,k,1)-DM a difference matrix with k rows
over a group of order q, HDF / HDM holey difference family / matrix,
MOILS mutually orthogonal idempotent Latin squares.

The CMTW forms quoted in the second half were re-read the same day
through an automated summary of the authors' open copy (Colbourn,
Martirosyan, Van Trung, Walker, "Roux-type constructions for covering
arrays of strengths three and four", DCC 41 (2006), uni-due.de), asked
formula by formula in three passes; that is a summary reading, not a
reading by eye, and it supersedes the earlier one-pass summary of the
same paper where the two differ (they agree on every formula both
give).

## 1. Yin's definition (p. 327-328), verbatim

Abstract: "A difference covering array with parameters k, n and q, or
a DCA(k, n; q) for short, over a group (G, •) of order q is defined to
be a k × n array (a_ij) with entries a_ij (0 ≤ i ≤ k − 1, 0 ≤ j ≤ n − 1)
from G such that, for any two distinct rows t and h (0 ≤ t < h ≤ k − 1),
every element of G occurs in the difference list {d_hj • d_tj^{-1} :
j = 0, 1, ..., n − 1} at least once. It is clear that n ≥ q in a
DCA(k, n; q). The equality holds if and only if a (q, k, 1) difference
matrix exists. It is well known that a (q, k, 1) difference matrix does
not exist, whenever q ≡ 2 (mod 4) and k ≥ 3. Thus, we have n ≥ q + 1
for these values of k and q."

Section 1: "By a difference covering (packing) array over G with
parameters k, n and q, or a DCA(k, n; q) for short, we mean a k × n
array (a_ij) with entries a_ij (0 ≤ i ≤ k − 1, 0 ≤ j ≤ n − 1) from G
such that, for any two distinct rows t and h (0 ≤ t < h ≤ k − 1), every
element of G occurs in the difference list Δ_th = {d_hj • d_tj^{-1} :
j = 0, 1, ..., n − 1} at least (at most) once."

"It is fairly obvious that the minimum (maximum) values of n is q + 1
(q − 1) in a difference covering (packing) array when a (q, k, 1)-DM
does not exist." [Read as the lower bound n ≥ q + 1; existence at
q + 1 is what Section 3 proves for k = 4.]

"All groups are assumed to be abelian throughout what follows. To
exclude the trivial case, k ≥ 3 is always assumed in a DCA(k, n; q).
Whenever the notation DCA(k, q; q) is used, it is understood to be a
(q, k, 1)-DM. Also, if a constant vector over G is added to a certain
row or a certain column of a DCA(k, n; q), then the derived array is
also a DCA(k, n; q). So we may, if we wish, assume that the first row
and the first column of a DCA(k, n; q) are both zero vectors."

Example 1.1: "The following array is a DCA(4, 3; 2) over the cyclic
group of order 2:" rows (0 0 0), (0 1 0), (0 0 1), (0 1 1).

Section 1 (p. 329-330), the link to covering arrays: from a DCA(k, n; q)
over G = {g_0 = 0, g_1, ..., g_{q−1}} one obtains "a CA(k, q; nq):
Ā = [A_0 | A_1 | ··· | A_{q−1}], where A_s = (a_ij + g_s)^T for
0 ≤ s ≤ q − 1. The derived CA from a DCA(k, n; q) is class-regular
(see [1] for its definition), and hence can be extended to a
CA(k + 1, q; nq). Furthermore, this array contains q disjoint rows".
In the living table's notation: CAN(2, k, q) ≤ q · n and
CAN(2, k + 1, q) ≤ q · n. (Yin writes CA(k, q; b) for k factors, q
symbols, b rows.)

So in Yin the array is k × n with k the number of factors and n the
number of runs; every element of G, ZERO INCLUDED, must appear as a
difference of each pair of rows; the group is any abelian group of
order q; λ = 1 in the sense "at least once".

## 2. Yin's results, verbatim

Theorem 2.1. "Suppose that there exist: (1) a (k, q; q_1, q_2, ..., q_r;
u)-HDM over (G; H_1, H_2, ..., H_r; H); (2) a (k, q_i; u)-HDM over
(H_i; H) for any i (1 ≤ i ≤ r − 1); (3) a DCA(k, n; q_r) over H_r. Then
there exists a DCA(k, q − q_r + n; q) over G."

Theorem 2.2. "Suppose that r ≥ 2 and there exist (1) a (K, q; q_1, q_2,
..., q_r; u)-HDF over (G; H_1, H_2, ..., H_r; H); (2) d − 2 MOILS(k) for
any k ∈ K. Then there exists a (d, q; q_1, q_2, ..., q_r; u)-HDM over
(G; H_1, H_2, ..., H_r; H)."

Theorem 2.3. "Suppose a (k, q; q_1)-HDF over (G; H) and d − 2 MOILS(k)
all exist. Then there exists a (d, q; q_1)-HDM over (G; H)."

Theorem 2.4. "Suppose that the following designs exist: (1) a
(k, v; h_1, h_2; u)-HDF over (G; H_1, H_2); (2) a (k, h_1 q; uq)-HDF
over (H_1 ⊕ Ḡ; H ⊕ Ḡ); (3) a (k, vw; h_1 w, h_2 w; uw)-HDF over
(G ⊕ S; H_1 ⊕ S, H_2 ⊕ S_j; H ⊕ S); (4) a (k, q; w)-HDM over (Ḡ; S).
Then there exists a (k, vq; h_2 q)-HDF over (G ⊕ Ḡ; H_2 ⊕ Ḡ)."

Theorem 2.5. "Let G and Ḡ be two groups with orders q and q̄,
respectively. Suppose that there exist: (1) a (k, q; q_1, q_2, ...,
q_r; u)-HDM over (G; H_1, H_2, ..., H_r; H); (2) a (k, q̄; w)-HDM over
(Ḡ; S); (3) a (k, qw; q_1 w, q_2 w, ..., q_r w; uw)-HDM over (G ⊕ S;
H_1 ⊕ S, ..., H_r ⊕ S; H ⊕ S); (4) a (k, q_j q̄; u q̄)-HDM over
(H_j ⊕ Ḡ; H ⊕ Ḡ) for any j (1 ≤ j ≤ r − 1). Then there exists a
(k, q q̄; q_r q̄)-HDM over (G ⊕ Ḡ; H_r ⊕ Ḡ)."

Corollary 2.1. "Let G and Ḡ be two groups with orders q and q̄,
respectively. Suppose that there exist: (1) a (q, k, 1)-DM over G;
(2) a (k, q̄; u)-HDM over (Ḡ; H); Then there exists a (k, q q̄; qu)-HDM
over (G ⊕ Ḡ; G ⊕ H)."

Lemma 3.1. "Let q = q_1 q_2 ··· q_t where each q_j is a prime power not
less than k. Then there exists a (q, k, 1)-DM, or equivalently a
(k, q; q_1)-HDM with q_1 = 1, and therefore k − 2 MOILS(q), over
⊕_{j=1}^{t} EA(q_j)."

Lemma 3.2. "Let m = 3^{α_0} 5^{2α_1 + r} p_2^{α_2} ··· p_t^{α_t} be the
prime factorization, where r = 0 or 1 and p_j's (2 ≤ j ≤ t) are all odd
primes not less than 7. Then the following HDFs over C_{6m} exist:
(1) a (4, 6m; 6)-HDF if (α_0, r) ≠ (0, 1) or (1, 0); (2) a (4, 6m; 18)-HDF
if (α_0, r) = (1, 0); (3) a (4, 6m; 30)-HDF if (α_0, r) = (0, 1)."

Lemma 3.3. "If q ≡ 1 (mod 6) is a prime power, then there exists a
(4, 2q; 2)-HDF over (C_2 ⊕ EA(q); C_2 ⊕ {0})."

Lemma 3.4. "There exist a DCA(4, 7; 6) over C_6, a DCA(5, 11; 10) over
C_10 and a DCA(4, 19; 18) over C_18." (The three arrays are printed;
each has a zero first row and a zero first column.)

Lemma 3.5. "There exists a (4, 30; 6)-HDM over (C_30; C_6)."

Corollary 3.1. "There exists a DCA(4, 31; 30) over C_30."

Lemma 3.6. "Let q be a prime power and q ≡ 5 (mod 6). Then there exists
a (4, 2q; 2)-HDM over (C_2 ⊕ EA(q); C_2 ⊕ {0})."

Theorem 3.1. "For any positive integer q ≡ 6 (mod 12), there exists a
DCA(4, q + 1; q)." (Proof: over C_q.)

Theorem 3.2. "For any positive integer q ≡ 2 or 10 (mod 12), there
exists a DCA(4, q + 1; q)." (Proof: q = 2u, u = q_1 ··· q_t the prime
factorization; the array is over C_2 ⊕ EA(q_1) ⊕ ··· ⊕ EA(q_t).)

Theorem 3.3. "For all positive integers q ≡ 2 (mod 4), there exists a
DCA(4, q + 1; q)."

Concluding remarks: "As shown in Lemma 3.4, a DCA(5, 11; 10) exists.
However, we failed in a computer search for a DCA(5, 7; 6) over C_6."

There is no table of DCAN values in the paper; the only numbers are
the arrays of Example 1.1, Lemma 3.4 and Corollary 3.1 and the
theorems above. Yin does not define covering ordered designs.

## 3. What the living table's theorems mean by DCAN, and the mapping

CMTW (Section 2, fetch reading): a DCA(N, Γ; t, k, v) over a group Γ of
order v is an N × k array such that for any t distinct columns j_1,
..., j_t the set of tuples (d_{i j_1} − d_{i j_2}, ..., d_{i j_1} −
d_{i j_t}), 1 ≤ i ≤ N, "contains every nonzero (t − 1)-tuple over Γ at
least once"; "When Γ = Z_v we omit it from the notation"; "We denote
by DCAN(t, k, v) the minimum N for which a DCA(N; t, k, v) exists."
In the proof of Theorem 3.4 the multiplication table of F_v (Theorem
2.2, Bush: "a (v, v; 1)-difference matrix over EA(v)") with its first
row removed is called a DCA(v − 1; 2, v, v). Cohen, Colbourn and Ling's
Theorem 3 is quoted as CMTW Theorem 3.3 with the same DCAN.

Differences from Yin, and the exact correspondence at t = 2:
- orientation: Yin's k × n array is the transpose of CMTW's N × k array
  (Yin: rows are factors; CMTW: columns are factors);
- coverage: Yin needs every element of the group, CMTW every NONZERO
  element. Normalise a Yin DCA(k, n; q) so one column is zero (Yin,
  p. 328), delete it: the remaining n − 1 columns give every nonzero
  difference, i.e. a CMTW DCA(n − 1; 2, k, q). Conversely a CMTW
  DCA(N; 2, k, v) with a zero column appended is a Yin DCA(k, N + 1; v).
  So DCAN_cmtw(2, k, v) = n_min(k, v) − 1, group for group;
- group: Yin's DCAs are over an arbitrary abelian group, CMTW's number
  DCAN(t, k, v) is over Z_v. Yin's arrays for q ≡ 2 (mod 4) are cyclic
  for every q ≤ 25 (C_2, C_6, C_10, C_18 explicitly; C_2 ⊕ EA(7) = C_14
  and C_2 ⊕ EA(11) = C_22 by Theorem 3.2 since 7 and 11 are primes).
  Yin's difference-matrix values (Lemma 3.1) are over ⊕ EA(q_j), which
  is Z_v only when v is squarefree; for v = 4, 8, 9, 12, 16, 18, 20,
  24, 25 the table's Lemma-3.1 entries are over a non-cyclic group
  (dcan_table.csv, column over_Zv). The Roux-type proofs in CMTW add
  DCA entries to covering array symbols and work over any abelian
  group of order v, so those entries serve as ingredients; the two
  RECURSIVE rows at v = 16 and v = 25 below rest on that remark, the
  five at prime v do not. Over Z_4 no (4, 3, 1)-DM exists (sum of the
  differences of a normalised third row would have to be 0 and 2 at
  once), so for v = 4, 8, 16 the cyclic number can be strictly larger
  than the EA value; not needed by any row.
- lower bound: Yin gives n ≥ q, hence DCAN_cmtw(2, k, v) ≥ v − 1, and
  n ≥ q + 1 (DCAN_cmtw ≥ v) for q ≡ 2 (mod 4), k ≥ 3.

## 4. The computed table (data/dcan_table.csv), 2 ≤ v ≤ 25

Columns v, k, group, over_Zv, n_yin (Yin's n), DCAN_cmtw (= n_yin − 1),
exact (TRUE when n_yin meets Yin's lower bound), source. Only (v, k)
with a bound in the paper are listed; every other cell has no bound
from Yin. What the paper gives, per v:
- k ≤ K1(v) = smallest prime power in the factorisation of v: n = v
  (Lemma 3.1), DCAN_cmtw = v − 1, exact. K1 = v for prime powers;
  K1 = 2 for v = 2, 6, 10, 14, 18, 22 (giving only the trivial k = 2);
  K1 = 3 for 12, 15, 21, 24; K1 = 4 for 20.
- v ≡ 2 (mod 4), k = 3, 4: n = v + 1 (Theorem 3.3; Example 1.1 at v = 2,
  Lemma 3.4 at 6, 10, 18, Theorem 3.2 at 14, 22; k = 3 by deleting a
  row), DCAN_cmtw = v, exact by n ≥ q + 1.
- v = 10, k = 5: n = 11 (Lemma 3.4), DCAN_cmtw = 10, exact.
Largest k with a bound: 3 or 4 or 5 at the non-prime-powers, v at the
prime powers; 177 entries in all, all exact. The rows need far more:
CCL's k-ary Roux search runs k' = 2..5000 (k_row 144..10000), CMTW's
vk forms need k' = k/v from 2 to 3072 and the 2k forms k/2 up to 5000.
Beyond the coverage above Yin's paper gives nothing; the only general
bound available is the observation (not in Yin, not in CMTW as read)
that a CA(N; 2, k, v) with a constant row deleted is a DCA(N − 1; 2, k,
v), DCAN_cmtw(2, k, v) ≤ CAN(2, k, v) − 1.

## 5. The CMTW forms used (summary reading, formula by formula)

- Theorem 3.3 [Cohen, Colbourn, Ling]: CAN(3, kl, v) ≤ CAN(3, k, v) +
  CAN(3, l, v) + CAN(2, l, v) · DCAN(2, k, v). No CODN variant is
  stated in CMTW.
- Theorem 4.1 (max(k, l) ≥ 4): CAN(4, kl, v) ≤ CAN(4, k, v) + CAN(4, l, v)
  + DCAN(2, l, v) CAN(3, k, v) + DCAN(2, k, v) CAN(3, l, v) + QCAN(k, l, v);
  with k, l ≥ 4 the CAN(3, ., v) terms become CODN(3, ., v).
- Lemma 4.2: QCAN(k, l, v) ≤ CODN(2, k, CAN(2, l, v)); Corollary 4.3 is
  4.1 with that. Lemma 4.4: QCAN(k, l, v) ≤ ceil(log_2 l) QCAN(k, 2, v);
  Lemma 4.5: QCAN(k, 2, v) ≤ CODN(2, k, v²); Corollary 4.6 is 4.1 with
  ceil(log_2 l) CODN(2, k, v²).
- Theorem 4.7 (Hartman): CAN(4, 2k, v) ≤ CAN(4, k, v) + (v − 1) CAN(3, k, v)
  + CAN(2, k, v²).
- Lemma 4.8 (k ≥ 4): CAN(4, 2k, v) ≤ CAN(4, k, v) + (v − 1) CAN(3, k, v)
  + CODN(2, k, v) CODN(2, v, v) + v CODN(2, k, v).
- Corollary 4.9 (v prime power, k ≥ 4): CAN(4, 2k, v) ≤ CAN(4, k, v) +
  (v − 1) CAN(3, k, v) + v² CAN(2, k, v) − v². (Its proof states
  CODN(2, v, v) ≤ v² − v for a prime power v, from Bush, and uses
  CODN(2, k, v) ≤ CAN(2, k, v) − 1, which the summary reading places in
  Section 2 near Corollary 2.4; the section number is unverified.)
- Theorem 4.10: CAN(4, 3k, 2) ≤ CAN(4, k, 2) + 6 DCAN(2, k, 2) +
  CAN(3, k, 2) + CAN(3, k + 1, 2) + 4 CODN(2, k, 2).
- Theorem 4.11: CAN(4, 3k, 3) ≤ CAN(4, k, 3) + 2 CAN(3, k, 3) +
  18 DCAN(2, k, 3) + CODN(2, k, 9) + 18; Corollary 4.12 replaces
  CODN(2, k, 9) by CAN(2, k, 9) − 1.
- Theorem 4.13 (v ≥ 4 prime power): CAN(4, vk, v) ≤ CAN(4, k, v) +
  (v − 1) CAN(3, k, v) + (v³ − v²) DCAN(2, k, v) + CODN(2, k, v²) + v⁴ − v².
  Corollary 4.14: CODN(2, k, v²) → CAN(2, k, v²) − 1. Corollary 4.15:
  → (v² + v) CAN(2, k, v) − 1 − v² (via Corollary 2.4), giving
  CAN(4, k, v) + (v − 1) CAN(3, k, v) + (v³ − v²) DCAN(2, k, v) +
  (v² + v) CAN(2, k, v) − 1 + v⁴ − 2v².
- Other CODN facts in CMTW: CODN(2, k, vw) ≤ CODN(2, k, v) CODN(2, v, w)
  + v CODN(2, k, w) (Theorem 2.5); no bound on CODN(3, k, v) is stated
  beyond the QCAN lemmas; CMTW's Section 5 says its strength-two
  ingredients come from Colbourn's tables and does not say where its
  DCAN or CODN values come from (no table of them).
CODN(t, k, v) is the least N of an N × k array in which every N × t
subarray contains every non-constant t-tuple; the count gives
CODN(2, k, w) ≥ w² − w, so CODN(2, k, w) = w² − w whenever the Bush
bound applies (w a prime power, k ≤ w).

## 6. What the calibration found (arith_formula_dcan.R, result file)

- Cohen-Colbourn-Ling, 318 rows: with Yin's DCAN the k-ary Roux is
  evaluable on every row (some k' ≤ Yin's coverage always exists), exact
  on none; the record sits below it on all 318, by a median 24% of N
  (1% to 65%). At the k' the Yin law picks, the DCAN the record would
  need is below Yin's exact value on all 318 rows, by a median of 9.9
  rows where Yin's value is 14 at the median; since Yin's values meet
  the lower bound, no DCA at those k' can do it: the DCAs the record
  used have k' beyond Yin's coverage, where Yin gives no bound. The
  integer search over all factorisations finds an integer DCAN on 100
  rows (77 with CAN(2, l, v), 73 with CAN(2, l, v) − 1), with a median
  20 candidate factorisations per row and no (v, k') pair with one
  value on three or more rows except three at v = 3 with the CAN − 1
  variant; chance hits, nothing admitted. 0 RECURSIVE, 318 OPEN.
- CMTW strength 4, 583 rows: 7 RECURSIVE, the k = v² rows at v = 11,
  13, 16, 17, 19, 23, 25, exact under Theorem 4.13 with k' = v,
  DCAN(2, v, v) = v − 1 (Yin, Lemma 3.1) and CODN(2, v, v²) = v⁴ − v²
  (CMTW's Bush bound applied at v², exact by the count): N = v⁴ +
  (v − 1) v³ + (v³ − v²)(v − 1) + 2 (v⁴ − v²). 11 RECURSIVE_TENTATIVE under
  Lemma 4.8 with one CODN(2, k/2, v) read off the record: 8 rows at
  v = 3 (value 32, where CAN(2, k/2, 3) − 1 is 35 to 37; the same rows
  read equally as Theorem 4.7 with CODN(2, k/2, 9) = CAN(2, k/2, 9) − 9 =
  288, the record does not separate the two) and 3 rows at v = 7 (value
  96, where CAN(2, k/2, 7) − 1 = 174). Single-row integer fits at v = 8,
  9, 11, 13 are in the csv and not tiered (the v = 8 one, 56 = v² − v,
  is impossible at k/2 = 2048). The 239 rows of the vk form with
  k' = k/v beyond Yin's coverage fix only the sum (v³ − v²) DCAN(2, k', v)
  + CODN(2, k', v²), with CODN(2, k', v²) outside the table for v ≥ 6;
  Corollary 4.15 (all ingredients in the table but DCAN) gives an
  integer DCAN on 0 of 239. The three k = 2v rows at v = 19, 23, 25 are
  Lemma 4.8 with CODN(2, v, v) = v² − v in both CODN terms less v − 1,
  an observation only. The 2 rows of Corollary 4.12 (v = 3, 3 | k) need
  DCAN(2, k', 3) = 4.83 and 11.44, non-integers. 239 rows at composite v
  with k even give no integer CODN under Lemma 4.8 with CODN(2, v, v) =
  CAN(2, v, v) − 1; 56 rows are reachable only through the Theorem 4.1
  products (DCAN, CODN(3, ., v), QCAN, none in the table). 565
  OPEN.
- Honest limit: Yin's bounds reach k ≤ 25 and the rows need k' in the
  hundreds to thousands; the tables' DCAN and CODN values at those k'
  came from elsewhere (Cohen-Colbourn-Ling's own search, presumably)
  and are not in either paper. A DCAN and CODN table at those k' is
  the missing ingredient; no fitted value here is admitted as a law.
