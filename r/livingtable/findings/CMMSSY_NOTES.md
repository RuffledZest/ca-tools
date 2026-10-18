# CMMSSY notes (Products of mixed covering arrays of strength two)

Colbourn, Martirosyan, Mullen, Shasha, Sherwood, Yucas, J. Combin.
Designs 14 (2006) 124-138, DOI 10.1002/jcd.20065. Read by eye from
the pdf on 2026-09-12, all 15 pages. The pdf is not in this
repository. Companion script: arith_formula_cmmssy.R, result
results/arith_formula_cmmssy_result.txt, classes data/arith_formula_cmmssy.csv.

## The statements, as printed

Notation: a PCA(N; 2, (k1, k2), v) is a CA(N; 2, k1 + k2, v) whose
last v rows, restricted to the first k1 columns, form a v x k1 block
P in which every column is a permutation of {1, ..., v} (Figure 3:
blocks A1, A2 above, P, X below). An SCA(N; 2, (k1, k2), v) is the
special case where, for 1 <= i <= v, row N - v + i has i in the first
k1 entries and 1 in the last k2 entries. When q is a prime power an
OA(2, q + 1, q) yields an SCA(q^2; 2, (q, 1), q).

Theorem 3.1. Suppose that there exist: (1) an MCA(N; 2, k, (v_1, ...,
v_k)), A, with profile (d_1, ..., d_k); (2) for each 1 <= i <= k, an
MCA(M_i; 2, l_i, (w_{i1}, ..., w_{i l_i})), B_i, with profile (f_{i1},
..., f_{i l_i}), and for which w_{ij} <= v_i for 1 <= j <= l_i. Then
for T = N + max_{i=1}^{k} (M_i - d_i), there exists an MCA(T; 2,
sum_{i=1}^{k} l_i, (w_{11}, ..., w_{1 l_1}, ..., w_{k1}, ..., w_{k l_k})).
(The profile (d_1, ..., d_k) counts the don't-care entries per column.)

Theorem 3.2. If a PCA(N; 2, (k1, k2), v) and an SCA(M; 2, (l1, l2); v)
both exist, then a PCA(N + M - v; 2, (k1 l1, k1 l2 + k2 l1), v) also
exists. (Remark after the proof: when the PCA is in fact an SCA, the
result is also an SCA.)

Theorem 3.3. When the SCA in Theorem 3.2 contains within B1 a v x eta
subarray, whose columns are permutations, the result is a
PCA(N + M - v; 2, (eta (k1 + k2), (l1 - eta)(k1 + k2) + k1 l2), v).
(Read by eye: the second component ends in k1 l2, so the total column
count l1 (k1 + k2) + k1 l2 is the same as in Theorem 3.2, only the
split moves. The paper adds that a similar observation applies to
permutation subarrays inside the PCA.)

Lemma 3.4. When q is a prime power, and r >= 0 is any integer, there
is an SCA((r + 1) q^2 - r q; 2, (q^{r+1}, (r + 1) q^r), q) and hence a
CA((r + 1) q^2 - r q; 2, q^{r+1} + (r + 1) q^r, q). Proof: apply
Theorem 3.2 inductively r times using an SCA(q^2; 2, (q, 1), q).
Small examples printed: CA(15; 2, 15, 3), CA(21; 2, 54, 3),
CA(27; 2, 189, 3), CA(28; 2, 24, 4), CA(40; 2, 112, 4), CA(52; 2, 516, 4),
CA(45; 2, 35, 5), CA(65; 2, 200, 5), CA(85; 2, 1125, 5), CA(91; 2, 63, 7),
CA(133; 2, 490, 7), CA(175; 2, 3673, 7).

Definition. For a non-negative integer r, D_{r,t} = sum_{i=1}^{s}
binom(r - i, i - 1) t^{r - i}, s = floor((r + 1) / 2); D_{0,t} = 0,
D_{1,t} = 1, D_{r+1,t} = t D_{r,t} + t D_{r-1,t}.

Lemma 3.5. When q is a prime power, and r >= 0 is any integer, there
is an SCA((r + 1) q^2 - r q; 2, ((q + 1) D_{r+1,q}, q D_{r,q}), q) and
hence a CA((r + 1) q^2 - r q; 2, (q + 1) D_{r+1,q} + q D_{r,q}, q).
Proof: the SCA(q^2; 2, (q, 1), q) has eta = q column permutations
within B1; Theorem 3.3 gives an SCA(2 q^2 - q; 2, ((q + 1) q, q), q)
with (q + 1) D_{2,q} + q D_{1,q} columns, and Theorem 3.3 is applied
with the SCA(q^2; 2, (q, 1), q) at each iteration. Small examples:
CA(15; 2, 15, 3), CA(21; 2, 57, 3), CA(27; 2, 216, 3), CA(33; 2, 819, 3),
CA(28; 2, 24, 4), CA(40; 2, 116, 4), CA(52; 2, 560, 4), CA(64; 2, 2704, 4),
CA(45; 2, 35, 5), CA(65; 2, 205, 5), CA(85; 2, 1200, 5), CA(105; 2, 7025, 5),
CA(91; 2, 63, 7), CA(133; 2, 497, 7), CA(175; 2, 3920, 7), CA(217; 2, 30919, 7).

Theorem 4.1 (direct construction). With an SCA(N; 2, (k1, k2), v) and
a binary code D(r, M) (M codewords of length r, every two codewords
having a position with 0 before 1 and a position with 1 before 0),
the array F_r is a CA(r (N - v) + v; 2, k, v) where k = k1^r +
(k1^{x_1} k2^{y_1} + ... + k1^{x_M} k2^{y_M}), x_j and y_j the numbers
of zeros and ones of codeword j.

Theorem 4.2. For r >= s >= 1 and q a prime power, an
SCA((r + 1) q^2 - r q; 2, (q^{r+1}, binom(r + 1, s) q^{r+1-s}), q) exists.
(The paper notes that a direct analogue of Theorem 3.3 can be written
but does not simplify the recursion.)

Section 5 (cover starters). A (g, l)-cover starter gives a
CA(l (g - 1) + 1; 2, l, g) (Meagher and Stevens). A (g, l)-distinct
cover starter (the l - 1 finite entries are all distinct) gives an
SCA(l (g - 1) + g; 2, (l, 1), g) and hence a CA((l + 1)(g - 1) + 1; 2,
l + 1, g). Lemma 5.1 lists (g, l)-cover starters for g = 3..9 (not
necessarily distinct). Distinct starters are printed for (5, 5..10),
(3, l >= 3), (4, l >= 6), (6, 8..12), (7, 7), (7, 9..13), (8, 11..14),
(9, 12..15). Lemma 5.2: for p >= 3 a prime, a (p, p)-distinct cover
starter exists. Worked examples: SCA(4 l + 5; 2, (l, 1), 5) and
Theorem 3.2 give SCA(4 (l1 + l2) + 5; 2, (l1 l2, l1 + l2), 5), hence
CA(45; 2, 35, 5), CA(49; 2, 41, 5), CA(53; 2, 48, 5), CA(57; 2, 55, 5),
CA(61; 2, 63, 5), CA(65; 2, 71, 5), CA(69; 2, 80, 5); with 65 tests,
200 factors by Theorem 3.2 twice, 205 by Theorem 3.3.

Also in the paper, for v = 3 and 4: a tabu-search CA(15; 2, 20, 3)
rewritten as a PCA(15; 2, (14, 6), 3) whose upper-left block holds 11
permutation columns in three rows (Figure 5), giving CA(21; 2, 74, 3),
CA(27; 2, 364, 3), CA(33; 2, 1312, 3); Figure 6: PCA(11; 2, (4, 1), 3),
PCA(12; 2, (4, 3), 3), PCA(13; 2, (6, 3), 3); Figure 7: PCA(19; 2, (5, 1), 4),
PCA(21; 2, (6, 1), 4), PCA(23; 2, (6, 2), 4). Section 6 (Theorem 6.1)
is the mixed-level SMCA generalization and is not used here.

## The law as the package implements it, and its calibration

CAs 0.24, productPCA(D1, D2): rows N + M - v; columns k1 l1 (left,
the new P block) + k1 l2 + k2 l1 (right); both factors may be PCAs
(the package cites a later generalization for that). With D2 absent
the package multiplies by SCA_Bose(v) and re-partitions the result
(Theorem 3.3 with eta = q, the "2PCA" of the tables).

Calibration: every one of the 447 CAs::PCAcat recipes re-derived from
the ingredients' (N, k, k1) with that law reproduces the catalogue's
N, k and k1 exactly (447 of 447 on all three). No PCAcat recipe uses
the one-argument (Theorem 3.3) form. All 85 cover-starter ingredients
(SCA_LCDST, SCA_MS, CS_CMMSSY) have N = (k - 1)(v - 1) + v and
k1 = k - 1, the Section 5 SCA form with l = k - 1. Three closure
matches were rebuilt with the package and verified with caverify:
SCA_LCDST(11, 8) x Bose(8) = SCA(134; 2, (88, 10), 8), Bose(13) x
Bose(13) = SCA(325; 2, (182, 13), 13), and that times Bose(13) =
SCA(481; 2, (2535, 182), 13); each equals the record at its k.

## Engine wiring

arith_pcax_recipes.csv lists the 44 exact PCAx matches (17 unresolved,
27 already engine-VERIFIED) as two table lookups (2, w, v), w the
ingredient's width, with N_pred = eCAN(2, w1, v) + eCAN(2, w2, v) - v
and the product's partition k1 and column count k_prod >= k. On all
44 rows both ingredient sizes equal the table's eCAN at their widths,
so the width lookup reproduces the record on every row. law_pcax in
arith_laws.R (dispatcher family "PCAx", tags PCAxPCA and PCAx2PCA)
reads that table; a row not in it returns NA. arith_formula_cmmssy.csv
carries only the 545 PCAx rows (family "PCAx"), so the tally has no
duplicate keys with arith_formula_dp_table.csv.

## What fits

- PCAx2PCA is Theorem 3.3 with the OA as the second factor (Lemma
  3.5 chains) or a cover-starter SCA times the OA; PCAxPCA is Theorem
  3.2. The closure (Theorems 3.2 and 3.3 over OA SCAs, PCAcat rows,
  the package's cover-starter and small-array ingredients, the (4, l)
  starters and Theorem 4.2; up to 5 products; dominated arrays
  pruned) reaches 44 of the 545 PCAx rows exactly, never beats the
  record, and reaches 443 more only above the record. 27 of the 44
  are already VERIFIED by the engine (Lemma 3.5 chains, cover-starter
  times OA products, and PCAcat rows the engine rebuilds); 17 are
  new RECURSIVE among the unresolved rows. Every exact match uses
  only the OA, PCAcat rows and package ingredients whose size is a
  table entry; no paper-only base array was needed.
- Row-count floor: the two-factor product theorems of the paper (3.2,
  3.3, and 4.1 at r = 2) give N + M - v rows on at most kA kB columns;
  a longer chain (Lemma 3.4, 3.5, Theorem 4.1 at r >= 3) is a pair
  product whose first factor is an earlier product, so the floor covers
  it only when that intermediate array is at or above the table's eCAN
  at its width, which is assumed here. So a product of two arrays of
  table size cannot go below S_min - v,
  S_min = min over kA kB >= k of eCAN(2, kA, v) + eCAN(2, kB, v).
  Of the 545 PCAx rows, 362 sit exactly at that floor, 182 above it,
  1 below it (a postop row). The 313 non-postop floor rows not
  reached by the closure are tiered RECURSIVE_TENTATIVE under the plain
  best-pair reading, as the 32 plain-exact generalized rows were
  tiered earlier; their partitions are not published.

## What does not fit

- "Direct product generalized": 1,522 of 1,573 rows are BELOW the
  N + M - v floor (d = S_min - N exceeds v by 1 to 75, median 14),
  so they are not Theorem 3.2, 3.3 or 4.1 products of two arrays of
  table size under any partition. Among the paper's constructions applied to two ingredients of table
  size, only Theorem 3.1 (don't-care profiles, T = N + max(M_i - d_i))
  can subtract more than v (Theorem 6.1, mixed levels, and ingredients
  below table size were not considered), and it
  needs the don't-care profile of the record's own first factor,
  which the tables do not publish. The closure reaches none of them
  exactly; 772 only above the record, 801 not at all.
- "Direct product", the 320 open rows: 230 are below the floor
  (same conclusion), 90 have d in 2..v-1 (consistent with Theorem
  3.1 at profile d, or with fewer than v shared constant rows; not
  decidable from the table), none at d = v or below 0. The closure reaches only
  the five k = 20000 cap rows at v = 7, 13, 16, 17, 19 (Lemma 3.5
  chains, already engine-VERIFIED).

## What is missing

- The partition (k1, k2) and the 2PCA width eta of the record's own
  rows; the tags "PCAxPCA", "PCAx2PCA", "Direct product" give none.
  For v = 21, 22, 23, 25 the base holds one array, for v = 24 none,
  so most rows there cannot be reached whatever the theorem.
- The don't-care profiles needed by Theorem 3.1 for the rows below
  the floor.
- A distinct-cover-starter list beyond g = 9 (Lemma 5.2 gives only
  (p, p) for primes, which is the OA size).
- Theorem 4.2 and the (4, l) starters were in the base and were never
  the cheapest route; Theorem 4.1 with a general code was not
  enumerated.
