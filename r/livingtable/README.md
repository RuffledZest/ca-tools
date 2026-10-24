# livingtable: a dependency-propagation engine for the covering array tables

## What this is

The Colbourn tables record the smallest known covering array for each
(t, k, v). Their maintainer's site is no longer public, and the R
package CAs (Groemping, GitHub version 0.24) ships a November 2024
snapshot of the tables as the dataset `colbournBigFrame` (13,641 rows
of t, v, k, N, Source), documented in `?colbournBigFrame` and in the
`ColbournTables.md` file of the CAs GitHub repository, together with per-family catalogues whose
rows carry executable recipes (`DPcat`, `PCAcat`, `CYCLOTOMYcat`,
`PALEYcat`, `ColbournKeriCombis`, and others such as `powerCTcat`).
Many entries are produced by constructions from smaller ingredient
entries, so an improvement at one entry changes the entries built on
it, and nothing public currently propagates such a change through the
tables. This directory is a propagation engine built on top of the CAs
catalogues.
Each catalogue recipe is a node, each ingredient call inside a recipe
is an edge, and the engine can find everything downstream of an
ingredient, rebuild those entries with a changed ingredient, verify
each rebuilt array with `caverify::ca_verify`, and cross-check the
incremental result against a full recompute. The directory also
carries the ledgers of the reproduction and verification campaign that
was run against the frozen snapshot, and the coverage accounting that
says which entries the engine can and cannot reach.

## How the engine is organized

All scripts run with `Rscript` from this directory. They read and
write CSV files in `data/`, and the stdout logs of the campaign runs
are kept in `results/`. Nothing is compiled.

The substrate is three files built from the CAs catalogues:

- `data/recipe_ingredients.csv`: one row per catalogue recipe (1,539
  recipes over five catalogues), with the recipe's code string and the
  list of ingredient calls parsed out of it (`parse_recipes.R`).
- `data/ingredient_dims.csv`: every unique ingredient call executed
  once and measured (876 calls, all resolved) (`ingredient_dims.R`).
- `data/ca_edges_v2.csv`: one row per (recipe, ingredient) pair,
  4,324 edges over 1,304 recipes, each with the ingredient's measured
  N, k and level range (`build_edges_v2.R`).

From these, `engine_closure.R` writes the two files the engine walks:

- `data/engine_nodes.csv`: one row per recipe, with its catalogue,
  row number, t, v, k, N and the canonical form of its code
  (1,539 nodes).
- `data/engine_links.csv`: recipe-to-recipe edges, present wherever a
  recipe's ingredient call is itself another recipe's code (412
  links). The closure script checks that this graph is acyclic.

`data/ca_edges.csv` is the earlier, coarser edge seed at the level of
(t, k, v) entries and construction families, produced from the
reproduction sweep. Its schema is described in
`LIVING_TABLE_SCHEMA.md`. The recipe-level files above supersede it
for the catalogues that carry code.

The engine has two modes, and they are required to agree:

- Graph mode (`engine_depquery.R`, `engine_walker.R`,
  `engine_substitute.R`, `mac_engine_demo.R`): start from an
  ingredient call, take its direct dependents from `ca_edges_v2.csv`,
  close transitively over `engine_links.csv`, and rebuild only that
  cascade. A substitution is done by evaluating each recipe in an
  environment layered over the CAs namespace in which the ingredient
  function returns the replacement array when called with exactly the
  target arguments.
- Sweep mode (`engine_sweep.R`, `mac_sweep.R`): re-evaluate every
  recipe in the web, with and without the substitution, and diff the
  sizes. The sweep is the correctness anchor. The set of entries the
  sweep says changed must lie inside the cascade graph mode predicted,
  and a disagreement is a bug in one of them, with the sweep winning
  until it is resolved.

Verification tiers used in the ledgers and logs:

- `EXECUTED`: the array was built and `ca_verify` confirmed full
  coverage at the declared strength (in the demo diff this tier is
  called `FULL`).
- `SCREEN4_PASS`: the array was too costly to verify in full within
  the run's budget, so four column windows (first 50, last 50, two
  random 50-column windows, narrower for high t in the powerCT
  re-audit) were each verified in full. A screen failure proves a
  defect because a subset of a covering array's columns must itself
  cover. A screen pass is not a certificate and is labeled as such.
- `GAPS_FOUND` and `FAILS(screen)`: coverage failed at the full or
  screen tier respectively.
- `ERR: TIMEOUT_KILLED`: the row's subprocess was killed at the
  15-minute limit in the retry pass (`mac_finish3.R`), after the row
  had already ended in an ERR in the earlier finishing pass.
- `ERR: TOO_LARGE_FOR_THIS_MACHINE`: the bare array would exceed the
  memory guard (2e8 cells by default) and was not attempted.
- `EXECUTED_POSTFIX` and `SCREEN4_PASS_POSTFIX`: the same tiers, in
  the re-audit run after the upstream fix of 2026-09-04.

## Coverage accounting

`data/ca_reproduction.csv` is the reproduction sweep over all 13,641
entries of `colbournBigFrame`: for each entry it asks `CAs::Ns(t, k, v)`
whether any implemented route reproduces the recorded N. Its `status`
column reads MATCH 985, BETTER 26, GAP 8,748, NOIMPL 3,834, ERR 48.

`engine_coverage.R` combines that with the recipe nodes and classifies
every entry. `data/engine_coverage.csv` says, over 13,641 entries with
no omissions:

| class | entries | share | meaning |
|---|---|---|---|
| VERIFIED | 987 | 7.2% | an implemented route or web recipe reproduces the recorded N exactly (985 MATCH rows plus 2 rows of sweep status BETTER for which a recipe node has the recorded N) |
| VERIFIED_IMPROVED | 24 | 0.2% | implemented routes beat the record |
| SEARCH | 3,623 | 26.6% | the Source tag names a search, CPHF or annealing origin, so there are no ingredients to propagate from |
| UNRESOLVED | 9,007 | 66.0% | everything else |

The SEARCH rows were not rebuilt. Their sweep status is GAP 3,036,
NOIMPL 570 and ERR 17, so the class repeats what the tag says and
does not say that an array was checked.

The UNRESOLVED count by strength is t=2: 2,920, t=3: 686, t=4: 850,
t=5: 1,670, t=6: 2,881.

`data/better_verified.csv` holds the 17 VERIFIED_IMPROVED entries that
were feasible to build and verify in full. All 17 verified, with
margins of 1 to 170 rows over the snapshot (routes TJ, CK_doublingCA,
ODbasedCA, DWYER). Since 2026-10-21 all 17 are covered by VERIFIED
rows of `table/ca_table.csv`: 11 by a row at their own k, 6 through a
row with more columns (stair-step).

The 9,007 UNRESOLVED entries are the subject of the arithmetic tier
below, which reads size laws off their Source tags and splits the
class into the remaining final classes in
`data/engine_coverage_v2.csv`.

### Class names

Every entry ends in one of nine classes. VERIFIED holds entries whose
recorded size an implemented route reproduces exactly, and
VERIFIED_IMPROVED entries where an implemented route beats it. These
are the engine's working labels and do not mean that every array was
checked: of the 985 MATCH entries in VERIFIED, 629 were built and
verified in full, 267 passed a four-window screen (16 of those were in
fact checked in full), 85 could not be finished on the machines used
and 4 failed (the ledgers below); of the 24 VERIFIED_IMPROVED, 17 were
built and verified in full. Nor are they the table's VERIFIED tier,
which holds only rows of `table/ca_table.csv` with an array hash and a
verification stamp. RECURSIVE holds entries whose
recorded size a construction reproduces exactly from ingredients in
the table, with nothing built. RECURSIVE_TENTATIVE is the same where
the reading may be a coincidence or one ingredient is not a table
quantity. RECURSIVE_STALE holds entries where the construction now
gives fewer rows than the entry. POST_OPTIMIZED holds entries where a
construction started the array and a post-optimization search
finished it, so the construction gives only the size before the
search. SEARCH holds the search-tagged entries with no table
ingredient. DIRECT_ONLY holds published one-off constructions and
search results with no table ingredient and no builder here. OPEN
holds the entries whose ingredients the tables never published. The
one distinction that matters is between an array that exists and has
been checked (the executed rows of VERIFIED and VERIFIED_IMPROVED) and
a size that only a construction accounts for (the RECURSIVE family). Two further names
appear in the code. UNRESOLVED is the internal name for the 9,007
entries between `engine_coverage.R` and the tally, and the family
scripts can label a row RECURSIVE_BELOW (record below the law) on the
way to the tally, which keeps that label at count 0. The `confidence`
column of the edge files keeps the vocabulary of
`LIVING_TABLE_SCHEMA.md` (EXECUTED, ARITHMETIC, CLAIMED), where
ARITHMETIC marks an edge whose size relation was checked without
building the array, the edge-level counterpart of RECURSIVE.

## The arithmetic tier

The verified engine reaches only entries with an executable recipe.
The 9,007 UNRESOLVED entries carry Source tags that name a
construction and its parameters, or a search result, but no
executable recipe. Where the tag names a recursive construction
(Power CT, Direct product, Add n factors, fuse, and so on) the size
is a function of the recorded sizes of other table entries, and the
arithmetic tier is that function, recovered per family and wired as
an engine organ. Every law is a size
relation over claims. Nothing in this tier is verified, it sits below
EXECUTED and SCREEN4_PASS, it is never blended with them, and a size it
propagates is reported as a claim derived from claims.

The ingredient lookup is `eCAN(t, w, v)`, the smallest N recorded in
the table at any k of at least w, which is what the table's own
entries use. A family's law is admitted only where it is exact. The
calibration gate is that the recorded N of every row of the family in
the frozen table must equal the law applied to the recorded sizes of
its ingredients, using no free parameter beyond what the tag states
(one exception, the Power N-CT hash family row count, is described in
the table). Rows that fail the gate are not admitted and are classed
by how they fail. The classes, over the 9,007 UNRESOLVED entries
(`data/arith_tally.csv`, `results/arith_tally_result.txt`):

| class | entries | meaning |
|---|---|---|
| RECURSIVE | 4,425 | a calibrated law reproduces the recorded N exactly from ingredient sizes that are themselves table entries, wired into the engine |
| RECURSIVE_TENTATIVE | 531 | the law is exact but an ingredient is not a table entry or the reading may be coincidental (310 PCA product rows at the plain best-pair floor, 117 Martirosyan-Colbourn rows with v of at least 6, 62 Power CZ rows with the paper's quilting array sizes, 32 Direct product generalized rows, 10 strength-4 CMTW rows with one fitted CODN value), not wired |
| RECURSIVE_STALE | 10 | the record sits above its own law, so the law claims a smaller array than the record, a lead and not a claim until the array is built |
| POST_OPTIMIZED | 380 | the tag carries a postop suffix (NCK or TJ-SA), so a construction started the array and a search finished it, 361 rows in the terminal families and 19 in families with a law, where the law gives the size before the search |
| DIRECT_ONLY | 339 | the tag names a published array or a search result with no table ingredient and no postop suffix (Augment OA 103, Add Factor SO 70, Torres-Jimenez 23, the Fix n symbols, cover starter, Raaphorst-Moura-Stevens, extended OA and cyclotomy tags, and the rest), so no propagation can ever reach the entry |
| OPEN | 3,322 | attempted, construction not recovered, because the ingredients the construction needs were never published |

The split of the 700 terminal rows into POST_OPTIMIZED and DIRECT_ONLY
is by the tag alone. A Source tag ending in `postop NCK` or
`postop TJ-SA` records a post-optimization pass over an array some
construction started, and 361 of the 700 carry it (321 NCK, 40 TJ-SA).
The other 339 carry no such suffix. The 19 postop rows of families
with a law (11 NCK, 8 TJ-SA) are POST_OPTIMIZED on the same rule.

The families and their laws, each calibrated on every row of the
family in the frozen table (counts from the result logs named in the
inventory, and "unresolved admitted" is the family's RECURSIVE count in
the tally):

| family | law | calibration on the table | unresolved admitted |
|---|---|---|---|
| Power CT | hash family of M rows over the columns of OA(q^e, q+1, q, e), row i a CA(t, w_i, v) with rho_i constant rows, N = chi + sum (N_i - rho_i) (Colbourn and Torres-Jimenez 2010, as restated in Theorem 2.1 of Colbourn and Zhou 2012; `CAs::DHHF2CA`, whose documentation gives it as Theorem 2.3 of the 2010 paper, a number not checked here), M = (e - 1) Turan(t, v) + 1 rows of the hash family from the transposed OA (Colbourn 2009, as restated in Lemma 2.4 of Colbourn and Zhou 2012; `CAs::createDHF`), tag grammar q^e, +p, T, S, Arc, c read from the record (Trin occurs only in Power N-CT tags) | 469 of 471 exact, 0 wrong, 2 inexpressible | 445 |
| Power N-CT | the same law with M not known from theory and solved from the record as one integer per (t, min(t, v), q, e), 39 keys, every row of a key giving the same integer, M plus or minus 1 fitting 0 of 2,093 rows | 2,033 of 2,093 exact, 0 wrong, 60 inexpressible | 2,033 |
| perfect hash family a,b,w [T r or S s] [,c] | the same law with M = a; the D16 form (na rows at a symbols, nb at b) N = na (eCAN(t, a, v) - 1) + nb (eCAN(t, b, v) - 1) + 1 | 612 of 612, and 8 of 8 for the D16 form | 620 |
| Direct product (plain tag) | N = min over pairs k1 k2 of at least k of eCAN(2, k1, v) + eCAN(2, k2, v) - v (Colbourn, Martirosyan, Mullen, Shasha, Sherwood and Yucas 2006, Theorem 3.2; `CAs::productCA`), 174 of 174 on the executed DPcat recipes | 212 of 545 exact; the generalized tag 32 of 1,573 with the record below the best pair on 1,522 | 206 |
| PCAxPCA, PCAx2PCA | Theorems 3.2 and 3.3 of the same paper, N = eCAN(2, w1, v) + eCAN(2, w2, v) - v with the two widths from a bounded closure of the products over the OA, the PCAcat rows and the package's cover starters (`arith_formula_cmmssy.R`, recipe table `data/arith_pcax_recipes.csv`), and the package's 447 PCAcat recipes reproduce on (N, k, k1) 447 of 447 | 44 of 545 exact (27 of them VERIFIED already), 313 at the plain best-pair floor and classed RECURSIVE_TENTATIVE, 182 above it, 6 postop | 17 |
| Derive from strength t+1 | N = floor(eCAN(t+1, k+1, v) / v) (Colbourn, Keri, Rivas Soriano and Schlage-Puchta 2010, inequality (7)) | 71 of 71 | 33 |
| Add n factors, Add a factor | b = k - n, N = eCAN(t, b, v) + sum over j = 2 to min(t, n+1) of v^(j-1) (v-1) eCAN(t-j, b-1, v); domain n of at most 2, or v a prime power with n of at most v, or n = 3 at v in 12, 15, 20, 21, 24; n = 1 is Theorem 3.2 of Colbourn, Keri, Rivas Soriano and Schlage-Puchta 2010, the sum for n of at least 2 and the domain are read from the record (no paper found) | 396 of 579 exact, 6 above inside the domain, 177 outside the domain | 391 |
| Chateauneuf-Kreher doubling | N = eCAN(3, k/2, v) + (v-1) eCAN(2, k/2, v) (Chateauneuf and Kreher 2002, restated as Theorem 2 of Cohen, Colbourn and Ling 2008) | 111 of 114, the 3 rows at v = 20 above the law | 95 |
| Martirosyan-Colbourn | h = k/2, N = eCAN(t, h, v) + (v-1) eCAN(t-1, h, v) + eCAN(t-2, h, v^2) (Martirosyan and Colbourn 2005, Corollary 2.2; the law was first read off the record, before a copy of the paper was available) | 37 of 38 exact where the third ingredient is a table entry (v of at most 5), 1 above; 117 rows at larger v exact with one constant per (t, v), classed RECURSIVE_TENTATIVE | 37 |
| fuse (every tag ending in m fuse words) | N = eCAN(t, k, v + m) - 2m at strengths 3 to 6 (Colbourn, Keri, Rivas Soriano and Schlage-Puchta 2010, Lemma 3.1, two rows fewer per fused symbol at every strength) | 1,303 of 1,354 exact, 42 with the base outside the table, 9 below the law | 147 |
| Colbourn-Martirosyan-TVT-Walker, strength 3 | N = eCAN(3, k', v) + (v-1) eCAN(2, k', v) + v^3 - v^2, k' = ceiling(k / v), at prime power v; at v + 1 a prime power, that row minus 2 | 28 of 28 (23 and 5) | 28 |
| Colbourn-Martirosyan-TVT-Walker, strength 4 | the k = v^2 rows by CMTW Theorem 4.13 with DCAN(2, v, v) = v - 1 from Yin 2003 and CODN(2, v, v^2) = v^4 - v^2 (derived here from CMTW's bound CODN(2, w, w) <= w^2 - w for a prime power w, applied at w = v^2 with v a prime power; not found in CMTW as read here), N = eCAN(4, v, v) + (v-1) eCAN(3, v, v) + (v^3 - v^2)(v - 1) + 2 (v^4 - v^2) (`arith_formula_dcan.R`, Yin's values in `data/dcan_table.csv`) | 7 of 7 such rows, 11 rows by Lemma 4.8 with one fitted CODN value classed RECURSIVE_TENTATIVE, 565 open | 7 |
| Martirosyan-TVT | even k, c = k/2, the size law `CAs::N_upper_MTVTRouxtypeCA` states at strength 5 and its shape one strength up at 6; odd k (the variant tag), the ingredient widths split over ceiling(k/2) and floor(k/2) as the unique full fit | 206 of 206 even, 160 of 160 odd, 6 postop rows bound only | 366 |
| Power CZ | Colbourn and Zhou 2012, Theorem 2.2, N = the least sum of quilting array sizes over the assignments Lemma 2.3 allows, sizes from the paper's Tables 1 and 2 (`arith_formula_powercz.R`, tables in `cz_tables.R`), a reading, nothing wired | 41 of 68 binary rows exact with the sizes as printed, 65 with two sizes fitted from the record, while the 27 ternary rows at strength 3, the 3 at strength 6 and the 117 rows at v = 6 have no ingredient in the paper | 0 (62 RECURSIVE_TENTATIVE) |
| Cohen-Colbourn-Ling | the k-ary Roux of CMTW Theorem 3.3 with Yin's DCAN values | 0 of 318, the record a median 24 percent below the law, so the difference covering arrays behind these rows were found by search | 0 |

References for the citations in the table above: C. J. Colbourn,
Distributing hash families and covering arrays, J. Combin. Inf. Syst.
Sci. 34 (2009) 113-126; C. J. Colbourn and J. Torres-Jimenez,
Heterogeneous hash families and covering arrays, Contemp. Math. 523
(2010) 3-15, doi:10.1090/conm/523/10309; C. J. Colbourn and J. Zhou,
Improving two recursive constructions for covering arrays, J. Stat.
Theory Pract. 6 (2012) 30-47, doi:10.1080/15598608.2012.647489 (notes
in `findings/POWERCZ_NOTES.md`); C. J. Colbourn, G. Keri, P. P. Rivas
Soriano and J.-C. Schlage-Puchta, Covering and radius-covering arrays:
constructions and classification, Discrete Appl. Math. 158 (2010)
1158-1180, doi:10.1016/j.dam.2010.03.008; S. S. Martirosyan and C. J.
Colbourn, Recursive constructions of covering arrays, Bayreuth. Math.
Schr. 74 (2005) 266-275.

The fitted N-CT hash family table (`data/arith_power_Mtable.csv`, 39
keys) carries a status column, `nct_status`, from a separate lane that
tested whether the fitted M is reached by the e = 2 Power CT hash
family with a chosen set of M directions of AG(2, q) in place of the
first Turan(t, p) + 1. CERTIFIED (32 keys) means such a set was found
and checked exactly, REFUTED (4 keys, t = 5 at q = 41 and 47, t = 6
with p = 6 at q = 41 and 43) means an exhaustive search proved that no
such set exists at that M, and OPEN (3 keys, t = 6 with p = 6 at q = 73
and 83 and with p = 4 at q = 71) means every search tried failed and
exhaustion was not run. A refuted key says that this mechanism cannot
produce the row at that parameter, not that the table row is wrong.
The statuses are in `data/nct_key_status.csv` and
`arith_formula_power.R` carries them into the table on a rerun.

The strength-4 rows of Colbourn-Martirosyan-TVT-Walker without a law
(565), the direct product rows without a law (1,861, of which 1,541
carry the generalized tag and 320 the plain tag), the 318
Cohen-Colbourn-Ling rows, the Add rows outside their domain (177),
the PCA product rows above the plain floor (182), Power CZ rows the
paper's tables do not reach (150), 60 power N-CT rows and 2 power CT
rows with an Arc reduction followed by a T reduction, and 7 fused
extended OA rows are the 3,322 OPEN entries.

Identity test (`arith_engine.R identity`,
`results/arith_engine_identity_result.txt`). The law evaluators in
`arith_laws.R` are a second implementation of the calibration scripts,
and the engine requires the frozen record to reproduce itself through
them. Result, 4,425 of 4,425 RECURSIVE entries reproduce their
recorded N. The run writes `data/arith_edges.csv`, 10,376 distinct
entry-to-lookup edges (14,149 lookups in all), the non-range lookups
answered by 1,929 distinct table rows, and 253 RECURSIVE entries are
themselves ingredients of other RECURSIVE entries, which is why
propagation has to iterate.

Propagation (`arith_engine.R demo` and `arith_engine.R propagate
file.csv`). An improvement is a row t, k, v, N, optionally with the
number of constant rows the new array is known to carry (default 1,
the only number any covering array guarantees, so a law that credits
an ingredient with v constant rows credits an improved ingredient only
for what it carries). Improvements are validated (known (t, v),
integer N of at least v^t, k of at least t, N below the current
lookup, k clamped to the table's widest row). Two modes, graph (only
the entries whose recorded lookups the improvement can move, applied
and repeated with the changed entries as the next round's
improvements) and sweep (recompute every RECURSIVE entry, apply,
repeat), are each iterated to a fixpoint and must agree on the
closure; a run in which they disagree stops and writes nothing.
The engine starts from the CITED rows of `table/ca_table.csv`
(`base_record.R`), which equal `colbournBigFrame` row for row; it
refuses a table whose CITED rows do not give the recorded fingerprint,
and needs only R, not CAs. Improvements are put in a fixed order
before anything else, so the result does not depend on the order of
the file. Where two improvements answer a lookup with the same N, the
one named in the working is the one with more constant rows, then the
earlier priority date (the date the work first appeared publicly,
column `priority_date`, else the date it was entered in the table,
column `entered`; a row with neither comes last), then the wider
array, then the smaller id (compared as text, so "10" sorts before
"9"). So among arrays of the same size the earlier work is credited.
A later one is named only where it carries more constant rows (a law
that credits constant rows may then give a smaller value from it), at
widths the earlier one does not cover, or against a row with no date.
An improvement that only equals the table is not accepted, and where
an improvement equals a frozen row at some width, the frozen row stays
named there.

Demo (`results/arith_engine_demo_result.txt`, `data/arith_cascade.csv`).
The 17 verified improvements of `data/better_verified.csv` were
offered and all 17 accepted. The closure is two entries, both from the
verified CA(3, 12, 14) at 3,381 rows (record 3,458). CAN(3, 24, 14)
goes from 6,279 to 6,202 by Chateauneuf-Kreher doubling, and
CAN(5, 23, 14) goes from 3,070,224 to 3,053,515 through the
Martirosyan-TVT variant law, 16,786 rows in all. Graph mode and sweep
mode both stop after two rounds and agree (the log's verdict line is
`TWO-MODE AGREEMENT ON THE CLOSURE: PASS`). Both new sizes are claims.
The doubling's other ingredient, the table's CAN(2, 12, 14) at 217
rows, is DIRECT_ONLY (Add Factor SO, a search result), so the
doubled array cannot be built here from table ingredients and neither
new size has been verified. The other 16 improvements move no
recorded lookup. Graph mode found two candidate entries in its first
round, both fed by CA(3, 12, 14), and none in the second.

The ten RECURSIVE_STALE rows are the only places where a law claims
more than the record, and each is a construction that has not been
executed. They are the three Chateauneuf-Kreher doubling rows at
v = 20, k = 36, 38, 40 (recorded 18,677, 18,753, 19,019 against the
law's 18,487, 18,563, 18,639, with the present eCAN(2, 18 to 20, 20)
as ingredient), six Add n factors rows, three at (t, v) = (5, 8) and
three at (5, 13), above the sum by 7, 12 and 24 units of v(v - 1),
each equal to the difference between the answering strength-3 row
and a neighboring row, and one Martirosyan-Colbourn row, (5, 4, 2374)
recorded 45,549 against 45,534. They are listed in
`results/arith_formula_small_result.txt`,
`results/arith_formula_addn_result.txt` and
`results/arith_formula_mc_result.txt`.

Coverage with the classes counted apart (`arith_coverage_republish.R`,
`data/engine_coverage_v2.csv`, `results/arith_coverage_republish_result.txt`),
over 13,641 entries with no omissions:

| class | entries | share |
|---|---|---|
| VERIFIED | 987 | 7.2% |
| VERIFIED_IMPROVED | 24 | 0.2% |
| RECURSIVE | 4,425 | 32.4% |
| RECURSIVE_TENTATIVE | 531 | 3.9% |
| RECURSIVE_STALE | 10 | 0.1% |
| POST_OPTIMIZED | 380 | 2.8% |
| SEARCH | 3,623 | 26.6% |
| DIRECT_ONLY | 339 | 2.5% |
| OPEN | 3,322 | 24.4% |

Entries with a handle (reproduced by a route 1,011, search-tagged 3,623, RECURSIVE
4,425, each counted apart) number 9,059 of 13,641, 66.4 percent. By
strength the share with a handle is 17.1 percent at t = 2, 70.1 at
t = 3, 64.5 at t = 4, 85.0 at t = 5 and 94.2 at t = 6. Strength two is
low because 2,697 of its 3,254 entries have no handle, among them the
direct product rows without a law (1,861), the PCA product rows (498
tentative, open or postop) and 304 terminal rows. Entries with no
handle (OPEN) are 3,322 in all, 24.4 percent, and 719 (POST_OPTIMIZED
and DIRECT_ONLY) can never be reached by propagation.

What stays open, and why. The three papers the tags name were read
by eye on 2026-09-12 and the notes are in `findings/`. Colbourn,
Martirosyan, Mullen, Shasha, Sherwood and Yucas (2006, J. Combin. Des.
14, `findings/CMMSSY_NOTES.md`) reproduce the package's 447 PCAcat
recipes exactly and 44 PCA product rows of the table, 17 of them new.
Their generalized product (Theorem 3.1) subtracts a don't-care
profile the tables never state, and 1,522 of the 1,573 generalized
rows and 230 of the 320 open plain rows sit below the N + M - v floor
that any product of two table-size arrays obeys, so those 1,861 rows
are open by a proven reason. Colbourn and Zhou (2012, J. Stat. Theory
Pract. 6, `findings/POWERCZ_NOTES.md`) state no formula. The tag is
the type column of their Tables 3 and 4, a least-cost reading of their
quilting arrays is exact on 65 of the 69 binary rows and is kept as
tentative, and the 117 rows at v = 6 have no ingredient in the paper.
Yin (2003, J. Combin. Theory A 104, `findings/DCAN_NOTES.md`) gives
difference covering array numbers only to k = 25. His values settle
seven strength-4 CMTW rows at k = v^2 and show the record on all 318
Cohen-Colbourn-Ling rows below the k-ary Roux evaluated with them, so
those difference arrays were found by search. The Add n factors law
outside its stated domain (177 rows) and the 62 power rows with an Arc
reduction followed by a T reduction were attempted and not recovered.
The 3,322 OPEN entries wait on data that was never published, the
product partitions and don't-care profiles, the Colbourn-Zhou
assignment rule and its v = 6 ingredients, and the search-found
difference covering arrays, not on anything in print.

## Verification campaign results

The campaign attempted to build and verify every MATCH entry of the
reproduction sweep with `CAs::bestCA` and `caverify::ca_verify` (`mac_grind.R`,
then `mac_finish2.R` with a subprocess and hard timeout per row, then
`mac_finish3.R` for the timeout pile at screen tier with a memory
guard). The two ledgers cover all 985 MATCH entries with no overlap:

`data/edge_executed_progress.csv` (716 rows):

| note | rows |
|---|---|
| EXECUTED | 629 |
| GAPS_FOUND | 2 |
| ERR: TIMEOUT_KILLED | 36 |
| ERR: TOO_LARGE_FOR_THIS_MACHINE | 49 |

`data/edge_screen_progress.csv` (269 rows):

| note | rows |
|---|---|
| SCREEN4_PASS | 267 |
| FAILS(screen) | 2 |

So 629 entries are fully certified, 267 pass a four-window screen,
85 are unresolved with a stated reason, and 4 failed. The final log of
the retry pass is `results/mac_finish3_result.txt` (its last line:
certified 629, failures 2, screened 267, still unresolved 85). Two
details of the ledgers: 16 of the 267 SCREEN4_PASS rows have k between
19 and 37, where a 50-column window is the whole array, so each of
those was in fact verified in full by an earlier version of the worker
that still labeled it a screen (the shipped `finish_one.R` labels such
rows EXECUTED), and three EXECUTED rows built one row smaller than the
snapshot, (2, 1728, 11) 359 to 358, (2, 8000, 19) 1079 to 1078 and
(2, 17576, 25) 1871 to 1870, all Direct product entries built via
recBoseCA_CA and verified at the smaller size.

The four failures are the four defects the campaign found, all in
frozen-table entries whose cited construction, as implemented in CAs
at the time, did not produce a covering array:

| entry | recorded N | how it failed | finding |
|---|---|---|---|
| CAN(3, 128, 6) | 762 | full verification, cyclotomy type 3a at q=127 | `findings/FINDING_CAN_3_128_6.md` |
| CAN(3, 2162, 20) | 43,220 | 50-column screen, cyclotomy type 3a at q=2161 | same finding |
| CAN(3, 2312, 21) | 48,531 | 50-column screen, cyclotomy type 3a at q=2311 | same finding |
| CAN(3, 1584, 2) | 64 | full verification, 123 gapped triples, powerCT with cover starter | `findings/FINDING_POWERCT_3_1584_2.md` |

The cyclotomy family audit (`mac_cyclotomy_audit2.R`,
`results/cyclotomy_audit2_result.txt`) covered all 213 rows of
`CYCLOTOMYcat`: 210 pass (16 full, 194 screen), the 3 above fail. The
follow-up (`results/cyclotomy_followup_result.txt`) ran multi-window
screens on the 194 screen-tier rows with zero new failures, and the
four-window screens pass for the type 3b sibling at the two large q.
The q=127 type 3b array (792 x 128) was fully verified, as recorded in
the finding. The per-row outputs are `data/cyclotomy_audit2.csv` and
`data/cyclotomy_screen4.csv`.

All four were fixed upstream in CAs on 2026-09-04 (GitHub commits
ae81661 for the cyclotomy rows, which now use type 4a at sizes
vq + v, and d1c6570 for the DHHF2CA defect behind the powerCT entry,
both dated 2026-09-04 in the repository history). The CAs `NEWS.md`
entry "September 05 2026, still version 0.24" describes both fixes.
The type 4a arrays were checked here: `results/mac_4a_q127_result.txt`
(768 x 128, full verification, 0 gaps of 341,376 projections) and
`results/mac_4a_result.txt` (43,240 x 2162 and 48,552 x 2312, 48
caverify windows each, all pass). The 14 powerCT rows the CAs author
had diagnosed as affected were re-audited with the fixed code
(`mac_powerct_refix.R`, `data/powerct_refix.csv`,
`results/powerct_refix_result.txt`): 2 full passes including
CAN(3, 1584, 2) at 64 rows, 12 screen passes, 0 failures. The main
ledgers were not re-run after the fix, so they still record the four
rows as failures of the pre-fix code.

## Acceptance evidence

Two-mode agreement (`mac_sweep.R`, `results/mac_sweep_result.txt`,
`data/sweep_agreement.csv`). Both full sweeps of the 1,539 recipes ran
with 0 construct errors. The wall time of the sweeps was not reliably
recorded (the timing line of the shipped log came from a units error
in `mac_sweep.R`, since corrected). The baseline sweep matched the catalogue's
recorded N at 1,531 of 1,539 recipes. The 8 mismatches are all DPcat
products (rows 49, 59, 62, 69, 87, 98, 110, 322) whose rebuilt array
is smaller than the catalogue records, seven by one row and DPcat 322
by two. Under a substitution that serves a one-row-fatter
`SCA_LCDST(5, 3)` everywhere, the sweep found 20 changed entries, the
graph cascade predicted at most 41, 0 changed entries lay outside the
predicted cascade, and 21 cascade members absorbed the change. Verdict
in the log: TWO-MODE AGREEMENT: PASS.

Demo and replay (`mac_engine_demo.R`, `results/engine_demo_result.txt`,
`data/engine_demo_diff.csv`). With the same fatter `SCA_LCDST(5, 3)`
payload: cascade 41 entries (41 direct). Baseline pass 41 entries,
verified 41, errors 0. Replacement pass 41 entries, verified 41,
errors 0. Restore pass 41 entries, verified 41, errors 0. Entries
changed by the replacement: 20 of 41 (absorbed unchanged: 21).
Rebuilt arrays verified covering: 41 of 41, all at tier FULL.
Baseline rebuilt sizes equal the recorded sizes: 41 of 41. After
restore, rebuilt sizes equal the recorded sizes: 41 of 41. Verdicts:
propagation test PASS (change propagated, every output verified),
replay test PASS (record reproduced after rewind and restore).

The shipped `results/engine_demo_result.txt` and
`results/mac_4a_q127_result.txt` were regenerated with the shipped
scripts on 2026-09-05 (a 2-core cloud machine, 2 workers for the demo), after
the scripts' output wording was changed, so that the logs are verbatim
output of the scripts as shipped. The regenerated
`data/engine_demo_diff.csv` was identical to the file produced on the
author's workstation.

## What is not done or untested

- The new-record form of the demo (a genuine improvement propagated
  to dependents and the improved sizes verified) has not been run. As
  of 2026-09-05 none of the verified improvements in
  `data/better_verified.csv` has dependents in the recipe web (they
  are high-strength leaves), so the demo uses a substitution payload
  (`fatter`, the ingredient with one duplicated row) instead. The
  code path is the same and accepts any replacement array from an
  `.rds` file.
- 9,007 of 13,641 entries (66.0%) are UNRESOLVED: no implemented route
  in CAs reproduces them and no recipe node matches them, so the
  engine cannot rebuild them. A further 3,623 are SEARCH rows, which
  were not rebuilt either. The arithmetic tier gives 4,425 of the
  9,007 a calibrated size law, as claims only, while 3,322 are OPEN and 719
  (POST_OPTIMIZED and DIRECT_ONLY) can never be reached by
  propagation.
- Nothing in the arithmetic tier is verified. The two propagated
  sizes of the demo, CAN(3, 24, 14) at 6,202 and CAN(5, 23, 14) at
  3,053,515, are claims from a verified ingredient through the
  record's own tags, and the ten RECURSIVE_STALE rows are constructions
  that have not been executed. Beyond the demo, the propagate mode is
  exercised by the reference inputs in `tests/` (`tests/README.md`),
  and no propagated size has yet been built and verified.
- The arithmetic laws for Martirosyan-TVT at strength 6, the odd-k
  Martirosyan-TVT variant, the Add n factors sum for n of at least 2
  and the D16 hash family form were read off the record, not from a
  paper. Each is exact on every row the engine admits; six Add n
  factors rows inside the stated domain sit above the sum and are not
  admitted (listed above). Each is labeled a reading in its script
  header.
  Four laws first read off the record have since been found in print:
  derive from strength t+1 is inequality (7), add one factor is
  Theorem 3.2 and the fuse loss of two rows per symbol is Lemma 3.1 of
  Colbourn, Keri, Rivas Soriano and Schlage-Puchta 2010, and the
  Martirosyan-Colbourn law is Corollary 2.2 of Martirosyan and Colbourn
  2005. Their script headers carry a note saying so. The paper of Colbourn,
  Martirosyan, Van Trung and Walker was read only through an
  automated summary of the authors' copy, in two passes (the second,
  formula by formula, is in `findings/DCAN_NOTES.md`). The Power CZ
  reading uses two quilting array sizes fitted from the record, and
  the Colbourn-Zhou Tables 1 and 2 in `cz_tables.R` and Yin's values
  in `data/dcan_table.csv` were transcribed from the papers by eye.
- `arith_formula_cmmssy.R` reads `data/arith_tally.csv` as shipped to
  mark which rows were open before its pass, and `arith_tally.R` then
  reads its csv, so the two are run in that order with the shipped
  tally in place. Its log and `data/arith_pcax_recipes.csv` were
  produced with the tally in its final state, which is why the log's
  open-row tables show the PCA product rows already classed.
- `results/arith_formula_dp_result.txt` was not regenerated in the
  packaging test (the script needs `data/engine_nodes.csv`,
  `data/recipe_ingredients.csv` and `data/ingredient_dims.csv`, which
  were not in the test copy). It is the log of the original run. Every
  other arithmetic-tier log was regenerated by the shipped scripts on
  2026-09-06, and every regenerated csv with an original to compare
  against (15 of 16) was byte-identical to it. The three paper passes
  were reproduced on 2026-09-12 with every csv byte-identical. The
  class names were changed afterwards by editing the string literals
  in the scripts, the class columns of the csvs and the labels in the
  logs, so the logs carry the new names without a fresh run.
  `mac_rename_check.R` reruns the tally and the republish and prints
  the class counts, so a run confirms the names.
- 85 MATCH entries remain unverified: 49 arrays are too large for the
  memory of one workstation (128 GB) and 36 hit the 15-minute limit
  per row in the retry pass. Screens of 50-column windows are not certificates.
- Several shipped data files predate the cyclotomy fix of 2026-09-04
  and reflect the three type-3a rows (CYCLOTOMYcat 5, 26, 29) at their
  old sizes 762, 43,220 and 48,531: `data/recipe_ingredients.csv` and
  `data/engine_nodes.csv` carry the old `type = "3a"` code,
  `data/sweep_agreement.csv` carries the old sizes in N_book and
  N_base, and `data/ca_reproduction.csv` records those three entries
  as MATCH via the CYCLOTOMY route, which `data/engine_coverage.csv`
  inherits as VERIFIED. With the current CAs, `Ns(3, 128, 6)` reports
  CYCLOTOMY = 768 against the snapshot's 762, so a rerun of the
  reproduction sweep would turn those three rows into GAP (MATCH 985
  would become 982 and VERIFIED 987 would become 984), and a rerun of
  `mac_sweep.R` against the shipped nodes would report 1,528 of 1,539
  baseline matches instead of 1,531. The reproduction sweep script is
  not shipped, so `data/ca_reproduction.csv` cannot be regenerated
  from this directory. Re-running `parse_recipes.R` and
  `engine_closure.R` regenerates the recipe and node files from the
  fixed catalogue (the packaging test confirmed that exactly those
  three rows change). None of the three rows is in the
  `SCA_LCDST(5, 3)` cascade used by the demo and the sweep test.
- The engine covers the five catalogues with executable code strings.
  `powerCTcat` and the other catalogues without code strings are not
  nodes in the web (the cyclotomy family was audited row by row, the
  powerCT family only partly, see the next item).
- The full powerCT family audit (`mac_powerct_audit.R`) was
  interrupted before completion and its partial checkpoint is not
  shipped. The fourteen author-diagnosed rows were re-audited after
  the upstream fix (`mac_powerct_refix.R`, `data/powerct_refix.csv`).
  The three construct errors that the partial run recorded for
  powerCA(6, 1332, 3) and powerCA(6, 1369, 3) ("invalid 'type' (list)
  of argument") remain unexamined and are listed here as an open item.
- The campaign scripts (`mac_grind.R`, `mac_finish2.R`,
  `mac_finish3.R`, the family audits) were run on a workstation with
  many cores and hours of wall time and have not been re-run in the
  packaging test. Their paths were adjusted to this layout in the same
  way as the tested scripts.

## How to run

Requirements: R, the CAs package (GitHub version, 0.24 or later, with
the 2026-09-04 fixes if you want the catalogues to match the findings)
and the caverify package from this repository (`r/caverify`, 0.2.0 or
later). No build step. Run everything from this directory. Network
access is needed for a full rebuild: several catalogue recipes and
`bestCA` routes download arrays from math.nist.gov (this affects
`ingredient_dims.R`, the sweeps and the campaign scripts).

The demo (about 1 to 5 minutes depending on cores, `cap` is the
full-verification cost budget, `workers` the number of parallel
processes):

    Rscript mac_engine_demo.R "SCA_LCDST(5, 3)" fatter 1e13 2 | tee results/engine_demo_result.txt

To propagate a real replacement array, save it with `saveRDS` and pass
the path in place of `fatter`. Output: `data/engine_demo_diff.csv`.

The two-mode sweep (both full sweeps, then the agreement check, uses
all cores but two by default):

    Rscript mac_sweep.R | tee results/mac_sweep_result.txt

The coverage accounting (about one second, rewrites
`data/engine_coverage.csv` from `data/ca_reproduction.csv` and
`data/engine_nodes.csv`):

    Rscript engine_coverage.R

Individual organs:

    Rscript engine_depquery.R "SCA_LCDST(5, 3)"        direct dependents of a call
    Rscript engine_depquery.R dims 11 5                 same, by ingredient dimensions
    Rscript engine_walker.R "PCAcat 1"                  rebuild and verify the cascade below a recipe
    Rscript engine_substitute.R identity "SCA_LCDST(5, 3)" 8
    Rscript engine_substitute.R swap "SCA_LCDST(5, 3)" repl.rds 8
    Rscript engine_sweep.R baseline out.csv [start] [end]
    Rscript engine_sweep.R swap "SCA_LCDST(5, 3)" repl.rds out.csv [start] [end]

Rebuilding the substrate from the installed CAs, in order:
`parse_recipes.R`, `ingredient_dims.R` (checkpointed, retries rows
that errored, rerun until it reports 876 of 876 resolved),
`build_edges_v2.R` (must report 0 unresolved), `engine_closure.R`.

The campaign scripts take optional `[cap] [workers]` arguments and are
documented in their headers. `finish_one.R` and `powerct_one.R` are
per-row workers launched by `mac_finish2.R`, `mac_finish3.R` and
`mac_powerct_refix.R` as subprocesses and are not run directly.

The arithmetic tier, in this order (each script reads the frozen
table inside CAs, except `arith_engine.R`, which reads the CITED rows
of `table/ca_table.csv`, and, most of them, `data/engine_coverage.csv`, writes
its csv to `data/`, and takes a few seconds apart from
`arith_formula_mtvt.R` at about a minute; the whole sequence ran in
about two minutes in the packaging test, plus about a minute for the
three paper passes):

    Rscript arith_measure.R | tee results/arith_measure_result.txt
    Rscript arith_formula_power.R | tee results/arith_formula_power_result.txt
    Rscript arith_formula_dp.R | tee results/arith_formula_dp_result.txt
    Rscript arith_formula_dp_table.R | tee results/arith_formula_dp_table_result.txt
    Rscript arith_probe_powerCZ.R | tee results/arith_probe_powerCZ_result.txt
    Rscript arith_formula_small.R | tee results/arith_formula_small_result.txt
    Rscript arith_families_probe.R | tee results/arith_families_probe_result.txt
    Rscript arith_formula_addn.R | tee results/arith_formula_addn_result.txt
    Rscript arith_formula_mc.R | tee results/arith_formula_mc_result.txt
    Rscript arith_formula_fuse.R | tee results/arith_formula_fuse_result.txt
    Rscript arith_formula_cmtw.R | tee results/arith_formula_cmtw_result.txt
    Rscript arith_formula_mtvt.R | tee results/arith_formula_mtvt_result.txt
    Rscript arith_families_tail.R | tee results/arith_families_tail_result.txt
    Rscript arith_formula_cmmssy.R | tee results/arith_formula_cmmssy_result.txt
    Rscript arith_formula_powercz.R | tee results/arith_formula_powercz_result.txt
    Rscript arith_formula_dcan.R | tee results/arith_formula_dcan_result.txt
    Rscript arith_tally.R | tee results/arith_tally_result.txt
    Rscript arith_engine.R identity | tee results/arith_engine_identity_result.txt
    Rscript arith_engine.R demo | tee results/arith_engine_demo_result.txt
    Rscript arith_coverage_republish.R | tee results/arith_coverage_republish_result.txt

`arith_formula_dp.R` reads the substrate files (`data/engine_nodes.csv`,
`data/recipe_ingredients.csv`, `data/ingredient_dims.csv`) and only
checks the law on the executed recipes. The family scripts do not
depend on it. `arith_formula_fuse.R` reads the probe's csv,
`arith_formula_cmmssy.R` reads the shipped tally (see above),
`arith_formula_powercz.R` sources `cz_tables.R`, `arith_tally.R`
reads every family csv, `arith_engine.R` reads the CITED rows of
`../../table/ca_table.csv` (or the table given by `--table=PATH`)
through `base_record.R`, reads `data/arith_tally.csv`
and `data/arith_power_Mtable.csv` and sources `arith_laws.R` (which
reads `data/arith_pcax_recipes.csv`), and the republish reads the
tally. `arith_formula_power.R` reads `data/nct_key_status.csv` to
carry the N-CT statuses into the Mtable. To confirm the class counts
after any change, `Rscript mac_rename_check.R` reruns the tally and
the republish and prints the counts of the nine classes against the
expected numbers. To propagate your own improvements, give a
csv with columns t, k, v, N and optionally nconst (constant rows the
array carries, default 1), priority_date or entered (YYYY-MM-DD) and
id:

    Rscript arith_engine.R propagate my_improvements.csv

The cascade is written to `data/arith_cascade_my_improvements.csv`.
Every size it contains is a claim.

## File inventory

| file | role |
|---|---|
| `README.md` | this file |
| `PIPELINE.md` | manifest: which script produces which file, in order |
| `LIVING_TABLE_SCHEMA.md` | design note for the edge schema and the two propagation modes |
| `parse_recipes.R` | parse catalogue code strings into ingredient calls |
| `ingredient_dims.R` | execute and measure every unique ingredient call |
| `build_edges_v2.R` | join recipes and ingredient dimensions into the edge file |
| `engine_closure.R` | recipe nodes, recipe-to-recipe links, DAG check |
| `engine_depquery.R` | reverse-dependency query for an ingredient |
| `engine_walker.R` | rebuild and verify the cascade below a recipe |
| `engine_substitute.R` | re-evaluate dependents with a replaced ingredient |
| `engine_sweep.R` | full recompute of every recipe, optional substitution |
| `engine_coverage.R` | coverage accounting of the 13,641 entries |
| `mac_sweep.R` | two-mode agreement run (baseline and swap sweeps versus graph cascade) |
| `mac_engine_demo.R` | live propagation with verification and change-and-restore replay |
| `mac_grind.R` | certification grind over MATCH entries |
| `mac_finish2.R`, `finish_one.R` | subprocess-per-row finishing run and its worker |
| `mac_finish3.R` | screen-tier retry of the timeout pile with memory guard |
| `verify_better.R` | build and verify the entries whose sweep status is BETTER |
| `mac_cyclotomy_audit2.R`, `mac_cyclotomy_followup.R` | cyclotomy family audit and follow-up |
| `mac_4a_check.R`, `mac_4a_q127.R` | checks of the type 4a repair |
| `mac_powerct_audit.R` | powerCT family audit |
| `mac_powerct_refix.R`, `powerct_one.R` | post-fix re-audit of the 14 diagnosed powerCT rows and its worker |
| `data/recipe_ingredients.csv` | recipes and their ingredient calls |
| `data/ingredient_dims.csv` | measured dimensions of each ingredient call |
| `data/ca_edges_v2.csv` | recipe-to-ingredient edges |
| `data/ca_edges.csv` | earlier entry-level edge seed |
| `data/engine_nodes.csv` | recipe nodes with t, v, k, N and canonical code |
| `data/engine_links.csv` | recipe-to-recipe links |
| `data/construction_families.csv` | Source tags of `colbournBigFrame` clustered into families |
| `data/ca_reproduction.csv` | reproduction sweep over all 13,641 entries |
| `data/engine_coverage.csv` | coverage class of every entry |
| `data/better_verified.csv` | the VERIFIED_IMPROVED entries built and verified in full |
| `data/edge_executed_progress.csv` | full-verification ledger of the campaign |
| `data/edge_screen_progress.csv` | screen-tier ledger of the campaign |
| `data/sweep_agreement.csv` | per-recipe sizes from the baseline and swap sweeps |
| `data/engine_demo_diff.csv` | per-entry diff of the demo (recorded, baseline, replacement, restored) |
| `data/powerct_refix.csv` | post-fix powerCT re-audit ledger |
| `data/cyclotomy_audit2.csv` | per-row output of the cyclotomy family audit (213 rows) |
| `data/cyclotomy_screen4.csv` | per-row output of the cyclotomy multi-window follow-up (194 rows) |
| `results/mac_sweep_result.txt` | log of the two-mode agreement run |
| `results/engine_demo_result.txt` | log of the demo and replay |
| `results/mac_finish3_result.txt` | log of the final retry pass of the campaign |
| `results/cyclotomy_audit2_result.txt` | log of the cyclotomy audit |
| `results/cyclotomy_followup_result.txt` | log of the cyclotomy follow-up |
| `results/mac_4a_result.txt` | log of the type 4a window checks at q=2161 and q=2311 |
| `results/mac_4a_q127_result.txt` | log of the type 4a full verification at q=127 |
| `results/powerct_refix_result.txt` | log of the post-fix powerCT re-audit |
| `findings/FINDING_CAN_3_128_6.md` | the cyclotomy finding |
| `findings/FINDING_POWERCT_3_1584_2.md` | the powerCT finding |
| `findings/CMMSSY_NOTES.md`, `findings/POWERCZ_NOTES.md`, `findings/DCAN_NOTES.md` | notes on the three papers read for the open families (the pdfs are not in the repository) |
| `arith_measure.R` | the ceiling of the arithmetic tier: the UNRESOLVED entries by tag family |
| `arith_formula_power.R` | Power CT and Power N-CT size law, calibrated on every power row |
| `arith_formula_dp.R` | direct product law checked on the executed DPcat recipes |
| `arith_formula_dp_table.R` | direct product law on the frozen table (best pair) |
| `arith_probe_powerCZ.R` | Power CZ probe (grammar and column rule read, size law not recovered) |
| `arith_formula_small.R` | Derive, Add 1 factor, Chateauneuf-Kreher doubling, perfect hash family |
| `arith_families_probe.R` | Add a factor, a recorded blind pattern search (nothing admitted), the terminal families |
| `arith_formula_addn.R` | Add n factors and Add a factor for every n, with the domain |
| `arith_formula_mc.R` | Martirosyan-Colbourn |
| `arith_formula_fuse.R` | the fuse suffix over the whole table |
| `arith_formula_cmtw.R` | Colbourn-Martirosyan-TVT-Walker (strength 3 admitted, strength 4 open) |
| `arith_formula_mtvt.R` | Martirosyan-TVT, even and odd k |
| `arith_families_tail.R` | the last 39 rows outside the paper-blocked families |
| `arith_formula_cmmssy.R` | the PCA product and direct product families against Colbourn, Martirosyan, Mullen, Shasha, Sherwood and Yucas 2006 |
| `arith_formula_powercz.R`, `cz_tables.R` | Power CZ against Colbourn and Zhou 2012, with their Tables 1 and 2 |
| `arith_formula_dcan.R` | Cohen-Colbourn-Ling and strength-4 CMTW with Yin's difference covering array numbers |
| `mac_rename_check.R` | reruns the tally and the republish and prints the class counts against the expected numbers |
| `arith_tally.R` | the class of every UNRESOLVED entry, joined from the family csvs |
| `arith_laws.R` | the law evaluators, one per admitted family (sourced by the engine) |
| `arith_engine.R` | identity test, arithmetic edges, and two-mode propagation to closure |
| `base_record.R` | reads the engine's base record from the CITED rows of the table and checks its fingerprint |
| `arith_coverage_republish.R` | coverage accounting with the arithmetic tier counted apart |
| `data/arith_formula_power.csv`, `data/arith_power_Mtable.csv` | per-row power calibration and the fitted N-CT hash family table, with the `nct_status` column |
| `data/nct_key_status.csv` | CERTIFIED, REFUTED or OPEN for each of the 39 N-CT keys |
| `data/arith_formula_dp_table.csv` | per-row direct product calibration |
| `data/arith_probe_powerCZ.csv` | per-row Power CZ probe |
| `data/arith_formula_small.csv`, `data/arith_families_probe.csv`, `data/arith_families_tail.csv` | per-row calibration of the smaller families, the probe and the tail |
| `data/arith_formula_addn.csv`, `data/arith_formula_mc.csv`, `data/arith_formula_fuse.csv`, `data/arith_formula_cmtw.csv`, `data/arith_formula_mtvt.csv` | per-row calibration of the Add, Martirosyan-Colbourn, fuse, CMTW and Martirosyan-TVT families |
| `data/arith_formula_cmmssy.csv`, `data/arith_pcax_recipes.csv` | per-row classes of the PCA product rows and the 44 exact product recipes as table lookups |
| `data/arith_formula_powercz.csv` | per-row Power CZ reading |
| `data/arith_formula_dcan.csv`, `data/dcan_table.csv` | per-row DCAN calibration and Yin's values in the CMTW convention |
| `data/arith_tally.csv` | every UNRESOLVED entry with its class and family |
| `data/arith_edges.csv` | entry-to-lookup edges of the RECURSIVE entries with the answering table row |
| `data/arith_cascade.csv` | the demo closure (two entries) |
| `data/engine_coverage_v2.csv` | coverage class of every entry with the arithmetic tier apart |
| `results/arith_*_result.txt` | the log of each arithmetic-tier script above (identity and demo logs for the engine) |
