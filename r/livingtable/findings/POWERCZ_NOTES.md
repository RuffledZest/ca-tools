# Power CZ: Colbourn and Zhou (2012), read by eye on 2026-09-12

Paper: C. J. Colbourn and J. Zhou, "Improving Two Recursive Constructions
for Covering Arrays", Journal of Statistical Theory and Practice 6 (2012)
30-47, DOI 10.1080/15598608.2012.647489. 18 pages, read by eye from
the pdf. Nothing was copied from the pdf, which is not in this repository.

The living table attributes 215 rows to it with the tag
`Power CZ e-q.u1-w2.u2-...` (212 UNRESOLVED). The tag is the "Type"
column of the paper's Tables 3 and 4 (e.g. `Power CZ3-13.3-12.6` is the
type 13^3 12^6 at k = 1368, N = 216, in Table 3): a hash family of
M = sum u_i rows on the q^e (plus extra) columns, u_i rows of width w_i.
Files: `arith_formula_powercz.R` (law and calibration), `cz_tables.R`
(the paper's Tables 1 and 2 transcribed by eye), result
`arith_formula_powercz_result.txt`, tiers `arith_formula_powercz.csv`.

## The statements, verbatim

Section 2, page 31-32:

> **Theorem 2.1** (Colbourn and Torres-Jiménez 2010) *Suppose that there exist*
> *1. a DHHF(M; k, k_1 ⋯ k_M, t, min(t, v)), and*
> *2. a CA(N_i; t, k_i, v) having ρ_i constant rows (rows containing a single symbol) for 1 ≤ i ≤ M.*
> *Let χ = max(0, Σ_{i=1}^{M} ρ_i − (M − 1)v). Then a CA(χ + Σ_{i=1}^{M}(N_i − ρ_i); t, k, v) exists.*

Page 32 (definitions, condensed to what the theorem needs): a *species* of
a t-way interaction is the multiset of its t values; an S-quilting array
S-QA(N; t, k, v) covers every interaction whose species is in the set S,
and S-QAN(t, k, v) is the smallest N. A Φ-separating heterogeneous hash
family Φ-SHHF(M; k, k_1 ⋯ k_M, t) is an M × k array with at most k_i
symbols in row i such that, for every species S and every t distinct
columns, some row ρ ∈ Φ(S) has different symbols in columns c_i, c_j
whenever v_i ≠ v_j; Ψ_i = {S : i ∈ Φ(S)}.

> **Theorem 2.2** *Let t be a positive integer. Suppose that a Φ-SHHF(M; k, k_1 ⋯ k_M, t) exists, and that a Ψ_i-QA(R_i; t, k_i, v) exists for each 1 ≤ i ≤ M. Then a CA(Σ_{i=1}^{M} R_i; t, k, v) exists.*

Page 33:

> **Lemma 2.3** *Suppose that a DHHF(M; k, k_1 ⋯ k_M, t, v) exists for which every two different columns agree in at most s − 1 rows. Let S contain all multisets of size t from {1, …, v}. Suppose that Φ : S ↦ 2^{[1,…,M]} satisfies |{i : {v_1, …, v_t} ∈ Ψ_i, 1 ≤ i ≤ M}| > (s − 1) · τ({v_1, …, v_t}). Then the DHHF is a Φ-SHF(M; k, k_1 ⋯ k_M, t).*

where τ({v_1, …, v_t}) = |{(i, j) : v_i ≠ v_j, 1 ≤ i < j ≤ t}| (page 33).

Page 34:

> **Lemma 2.4** (Colbourn 2009b) *Whenever q is a prime power and (s − 1)T(t, v) ≤ max(q, s), there is a DHF((s − 1)T(t, v) + 1; t, q^s, q).*

with T(t, v) the Turán number. The text adds that these DHFs come from
the transpose of an OA(q^s, q+1, q, s), in which two columns agree in at
most s − 1 rows, and that Colbourn and Torres-Jiménez (2010) truncate
them to heterogeneous families.

Section 3 gives the quilting array sizes: Lemma 3.1 (juxtaposition),
Lemma 3.2 (derivation), Lemma 3.3 (a counting lower bound), Corollary
3.4, Lemma 3.5 (Tang-Chen characteristic vectors), Lemma 3.6 (Steiner
systems), Lemma 3.7 (a Roux-type doubling for S^4_2), Lemma 3.8 (column
replacement for T^t_x arrays), and the two tables:

* Table 1, page 37: S^t-QAN(t, k, 2) upper bounds, t = 4, 5, 6, k = 2..23,
  for the species sets S^t_{a,b} (binary weights a..b) listed per strength.
* Table 2, page 39: T^t-QAN(t, k, 3) upper bounds, t = 3..6, k = 3..25,
  for the sets T^t_x (every ternary species with at least x unequal pairs).

Section 4 (page 38): "Table 3 gives a number of applications of Theorem
2.2 for binary covering arrays using the ingredients from Table 1. The
type specified is the type of the heterogeneous hash family used; for
details, see Colbourn and Torres-Jiménez (2010)." Table 4 is the
ternary analogue with Table 2. The assignment Φ used is not stated.

Section 5 (pages 41-45), the second construction, not used by any Power
CZ row:

> **Theorem 5.1** *Suppose that for each 2 ≤ i ≤ t, a CA(N_i; i, k, v) exists. Then a CA(N_t + (v − 1)N_{t−1} + Σ_{i=2}^{t−2} N_i N_{t−i}; t, 2k, v) exists.*

> **Theorem 5.2** *For 2 ≤ i ≤ t, let A_i be a CA(N_i; i, k, v) exists. Let r_1, …, r_N consist of all distinct rows that appear in one or more of A_2, …, A_{t−2}. For 1 ≤ i, j ≤ N, when i ≠ j let M_{i,j} = {m : r_i appears in A_m, r_j appears in A_{t−m}, and 2 ≤ m ≤ t − 2} ∪ {t − 1 if r_i appears in A_{t−1} and there exists p, 1 ≤ p < v, for which r_j = π^p(r_i)}. For 1 ≤ i ≤ N, let M_{i,i} = {m : r_i appears in A_m and in A_{t−m}, and 2 ≤ m ≤ t − 2} ∪ {t if r_i appears in A_t}. Then CAN(t, 2k, v) ≤ N_t + (v − 1)N_{t−1} + Σ_{i=2}^{t−2} N_i N_{t−i} − Σ_{1≤i,j≤N, M_{i,j}≠∅} (|M_{i,j}| − 1).*

> **Lemma 5.3** *When q is a prime power and t ≥ 5, CAN(t, 2q, q) ≤ (t − 1)q^t − (t − 3)q^{t−1} − q q^{⌈t/2⌉} and CAN(t, 2q + 2, q) ≤ (t − 1)q^t − (t − 3)q^{t−1} − q^{⌈t/2⌉}.*

> **Lemma 5.4** *When q is a prime power and t ≥ 6, CAN(t, 2q, q) ≤ (t − 1)q^t − (t − 2)q^{t−1}.*

## The law calibrated

Theorem 2.2 gives N = Σ_i R_i and nothing more; with Lemma 2.3 (s = e,
the OA of strength e) the admissible assignments are those in which
every species S lies in Ψ_i for more than (e − 1)τ(S) rows. The law is
therefore the minimum of Σ_i QAN(Ψ_i, t, w_i, v) over admissible
assignments, with the sizes of Tables 1 and 2; it is solved exactly by a
dynamic programme over the rows (state: rows that missed each species
class, capped at the allowance M − r; ≤ 3 000 states). Readings:

* L1: every Table 1 set and its mirror; constants inside a row at the
  table's price or appended at 1 row each.
* L2: nonconstant sets only, v constant rows appended (Theorem 2.1's
  accounting).
* L3: nested symmetric sets S_{j,t−j} only (species with τ ≥ j(t − j),
  the analogue of Table 2's T_x).
* L4: L3 plus the two one-constant arrays S_{0,t−1} and S_{1,t}.
* L4f: L4 with two ingredient values fitted from the record at t = 6:
  the S_{1,5}-type array costs 299 at width 19 (Table 1 prints 298) and
  275 at width 18 (Table 1 prints 279; 275 is not a Table 1 value at
  width 18). 23 rows with 11..18 rows of width 19 and 7 rows with one
  row of width 18 agree on the two numbers (N − N_L4 = n_19 − 4 n_18 on
  all 24 rows carrying either width).

Ternary rows use Table 2's nested T_x sets; L1 and L4 coincide there.

## What fits (exact counts, 215 rows)

| block | rows | L1 | L2 | L3 | L4 | L4f |
|---|---|---|---|---|---|---|
| t=4 v=2 e=2 | 3 | 3 | 2 | 2 | 3 | 3 |
| t=4 v=2 e=3 | 17 | 12 | 7 | 9 | 14 | 14 |
| t=4 v=2 e=4 | 5 | 0 | 5 | 5 | 5 | 5 |
| t=5 v=2 e=3 | 2 | 2 | 0 | 0 | 2 | 2 |
| t=6 v=2 e=3 | 41 | 0 | 0 | 0 | 17 | 41 |
| t=6 v=3 e=2 | 3 | 0 | 0 | 0 | 0 | 0 |
| t=3 v=3 e=3 | 27 | 0 | 0 | 0 | 0 | 0 |
| t=5 v=6 e=3 | 117 | 0 | 0 | 0 | 0 | 0 |
| total | 215 | 17 | 14 | 16 | 41 | 65 |

L4 with the paper's sizes as printed is exact on 41 of the 68 binary
rows and L4f on 65; the three misses are the q = 9 rows at t = 4
(9^9, 9^8 5^1, 9^8 6^1), whose record is 8 below any assignment Lemma
2.3 allows (the record puts the weight-1 species in 5 rows where Lemma
2.3 needs 7; the paper's own Table 3 has the same 184 for 9^9).

Tiers: 65 RECURSIVE_TENTATIVE (the ingredient sizes are the paper's Table 1 as printed,
not the living table's eCAN (the living table is smaller than the
full-CA column of Table 1 on 14 cells, for instance CAN(6, 19, 2) = 285
against 299; with those substituted 24 of the 65 stay exact and 41 do
not), and two of them are fitted, 24 of the 65 rows needing a fitted
value), 150 OPEN,
0 RECURSIVE, 0 RECURSIVE_STALE. Of the 212 unresolved entries, 62 become
RECURSIVE_TENTATIVE. Nothing is wired into arith_laws.R: the law needs the
paper's tables, which the living table does not carry, and the
admitted reading is a lead on a stated domain (v = 2, widths ≤ 23,
q ≥ 11), not a law.

## What does not fit, and why

* **t = 3, v = 3 (27 rows).** Every tag has M = 6 rows at e = 3 where
  Lemma 2.4 gives 2 T(3,3) + 1 = 7 and Lemma 2.3 needs more than 6 rows
  for the all-distinct species; no admissible assignment exists. The
  hash family is not the paper's. Decomposing the record into Table 2
  sizes with no requirement at all is possible for 26 rows but
  inconsistent (14^6 only as six T_3 plus 3 constant rows; 16^6 only as
  two T_2 and four T_3 with no constant rows; 23^1 22^4 20^1 not at all),
  so Table 2 is not the ingredient library of these rows either. The
  Theorem 2.1 accounting with the living table's eCAN (every row a CA
  less its 3 constant rows, plus 3) is above the record by 6..19 on all
  27 rows: the missing ingredients are smaller quilting arrays of
  unknown size. The paper's own Table 4 (20^6 = 333, 19^6 = 318) also
  uses 6 rows, and its 11^6 10^4 = 354 at e = 4 puts the τ = 2 species
  in 3 rows where Lemma 2.3 wants 7: the paper's assignment rule is
  looser than its Lemma 2.3 and is not stated.
* **t = 6, v = 3 (3 rows).** 19^13 at e = 2: Lemma 2.3 minimum 50 273
  with Table 2, record 49 598 (675 below). 27^12 26^1 and 27^13: width
  27 is beyond Table 2 (k ≤ 25); no size available.
* **t = 5, v = 6 (117 rows).** The paper has no quilting arrays for
  v = 6 (Tables 1-2 are binary and ternary only; the text says the
  technique "also applies when the number of symbols is larger" without
  data). The residual against the Power CT law (eCAN(5, w, 6) − 1 per
  row) is −77 874..−76 444 and takes 45 values on 117 rows; it moves in
  steps of 54 and 30 with the count of width-22 rows and is not an
  additive function of the width counts (best additive fit misses by up
  to 3 519), i.e. a per-row saving that depends on which species set a
  row carries, exactly the shape of Theorem 2.2 with unknown v = 6
  quilting arrays. No lead beyond that.
* **The paper's own Table 3 at t = 6** (19^19 = 4 969, 19^18 17^1 =
  4 904) is far below the Lemma 2.3 minimum with its own Table 1 (5 348,
  5 284) and far below the living table (19^18 17^1 = 5 344): the paper's
  binary strength-6 entries were superseded, and the living table's
  rows are the recomputed ones.
* **What RECURSIVE_STALE would have meant.** Without the two fitted values,
  the 23 rows at q = 19 sit 3..10 above L4, i.e. Table 1's 298 for
  S_{1,5} at width 19 would give smaller arrays than recorded; the
  record behaves as if that array had 299 rows. This is read as a
  corrected ingredient, not as an improvement candidate.

## Missing ingredients, summarised

1. Quilting array sizes for v = 6 (all 117 rows at t = 5), absent from
   the paper.
2. Quilting arrays for v = 3 at width 27 (2 rows), beyond Table 2.
3. The 6-row hash family and the ingredient library behind the t = 3,
   v = 3 rows (27 rows), not described in the paper.
4. The assignment rule Φ the authors actually used, not stated; the
   living table's binary rows (except q = 9) are consistent with the
   Lemma 2.3 minimum over nested sets (L4), the paper's own Table 3
   entries are not.
5. Two Table 1 values at t = 6 (width 19 and 18, S_{1,5}-type) that the
   record contradicts, fitted, corroborated by 23 and 7 rows.
