# A provenance-tracked table of best-known covering array sizes

First published 2026-08-23 as a dated snapshot; since 2026-10-18 a
living table that grows by pull request (`../submissions/README.md`).
It replaces folklore with evidence: every entry says where it came
from, and several hundred entries carry machine verification stamps
tied to explicit arrays you can check yourself. Counts below are as
of 2026-10-21. Improvements are not yet propagated through recursive
constructions: the engine in `../r/livingtable` is run by hand and is
not connected to submissions, so no row here is derived by it.

## What is here

- `ca_table.csv` - the table, 14,205 rows, append-only, one row per
  evidence event. Schema below.
- `ca_table.rda` - the same table as a compressed R data frame
  (object `ca_table`), regenerated from the CSV by
  `ca_table.R::make_rda()`.
- `ca_table.R`, `ca_table.py` - small query helpers for R and Python
  (best known N, stair-step, verified rows). No dependencies.
- `arrays/` - 286 explicit arrays in canonical form (0-based integer
  symbols, one run per line, space separated; `NA` marks a don't-care
  entry, see below). 229 equal the best-known size for their
  parameters and 57 are SMALLER than the November 2024 snapshot's
  recorded best (the MANIFEST `status` column separates `equals_best`
  from `exceeds_snapshot`). File names are `CA_N_t_k_v.txt`, with a
  hash suffix where two distinct arrays share parameters. An array
  is stored when it equals or beats the best known size at entry; the other
  246 VERIFIED rows (143 NIST, 100 Dwyer, 3 CAs), all above the best
  known size, carry the hash, stamp and recipe, so the array can be
  fetched again and checked against its hash.
- `MANIFEST.csv` - one row per array file: parameters, status,
  SHA-256 of the canonical file content, retrieval recipe,
  verification stamp, and `constant_rows` (added 2026-10-20): the
  largest number of rows of the array that can be made constant by
  permuting symbols within columns, at most v. It is a property of
  the array that matters when the array is an ingredient of another
  construction. Computed by `../tools/constant_rows.c`, a standalone
  version of `cafast::maxconstant_c`, and checked against cafast on
  every array on file by `../tools/constant_rows_check.R`. The
  submission check computes it for every new array (empty, with the
  reason in the report, when the ten-minute budget is exceeded or the
  program could not be built). Whether an array splits into the
  blocks a product construction needs (its partition profile) is not
  computed; it is recorded only when the construction states it.
- `VERIFICATION_LOG.md` - the record of the verification runs that
  produced the stamps.
- `verify_pipeline.R` - the canonicalization, hashing, and
  verification code used to stamp rows, so anyone can stamp new ones
  the same way.

Some arrays contain `NA` don't-care entries. Verification uses the
"promise" semantics: coverage holds on the concrete entries alone, so
these arrays remain covering no matter how the don't-cares are filled.

The 57 `exceeds_snapshot` arrays are published work, chiefly
Torres-Jimenez arrays shipped in the CAs package and the 23 arrays of
Mickael Bergeron's submission, whose run sizes beat the
November 2024 snapshot's recorded rung at their parameters. The
improvements belong to their published sources; this table's
contribution is only the verification stamp and the side-by-side
accounting. Each such row's notes name the snapshot value it beats.

## Schema

`t, v, k, N` is the claim, with stair-step semantics: the row means
"N runs suffice for a strength-t covering array on up to k columns of
v symbols". `tier` is the evidence class:

- `CITED` - traceable to a dated snapshot or publication, no array in
  hand. The 13,641 baseline rows are the November 2024 status of the
  Colbourn tables, taken from the `colbournBigFrame` snapshot that
  Ulrike Groemping preserved in her CAs package after the original
  site (public.asu.edu/~ccolbou) became unavailable.
- `VERIFIED` - an explicit array is in hand and was checked
  exhaustively by the caverify kernel at the claimed strength. The
  row carries the array's SHA-256 (canonical form) and a stamp naming
  the caverify version, date, and machine.
- `FAILED_PENDING_RECHECK` - a verification attempt that failed its
  dimension check. Kept because history is never rewritten; each such
  row is superseded by a later resolution row. The three present at
  publication share one cause, per U. Groemping: the Dwyer
  CA_Database holds two arrays for some parameter sets and dwyerCA
  always fetches the smaller, so walking the catalogue trips the
  dimension check on the larger twins (VERIFICATION_LOG.md has the
  three pairs). All three arrays verify at their actual sizes.
- `SCREENED` - an array too large for the public check, screened on
  random column windows instead of verified in full (see
  `../submissions/README.md`). Listed but not counted as best known;
  when the array is later verified in full it gets a new VERIFIED row
  (below).
- `DISPUTED` - reserved for verification failures that survive
  recheck. None at publication.

`source_id` names the source class (S1 Colbourn snapshot, S4 NIST
covering array library, S5 Dwyer CA_Database, S6 the CAs package's
data and constructions, S7 literature and community submissions). `source_detail` is the exact
retrieval or generation recipe. `snapshot_id` dates the source.
`lb, lb_evidence` are reserved for lower-bound evidence and are empty
in this version. `construction` (added 2026-10-20) names the
construction or search that produced the entry, in the words a
covering array researcher would use. For the CITED baseline rows it
is Colbourn's own construction label, the same text as their
`source_detail`. For arrays entered through the submission check it
is the submitter's `construction` field, which the check requires.
For the 530 verified rows that entered from the NIST library, the
Dwyer database and the CAs package before the column existed, it was
filled on 2026-10-20 from the catalogues that describe those sources
(NIST ipof directory, `CAs::DWYERcat$Source` with Dwyer's own method
code quoted verbatim, `CAs::TJcat`, `CAs::CAEX_CAs`, and the KSK call
itself), by `tools/backfill_construction.R` and
`tools/apply_construction_backfill.py`; the mapping with its basis
per row is `construction_backfill.csv`. Nothing was inferred: a value
names the catalogue entry it was read from, and the Torres-Jimenez
arrays say that the method is not recorded per array. The notes of a submission row
say "exceeds table: previous best N (row k=..., source)" once; that
is the comparison the check made at entry, and it is not repeated.

## Reading the table from code

The CSV at
https://raw.githubusercontent.com/chrispbsmolen/ca-tools/main/table/ca_table.csv
is the whole table, always current, and the only interface. There is
no separate API. The stair-step rule gives the best known N at
(t, v, k) as the smallest N among rows with tier CITED or VERIFIED,
the same t and v, and k at least the requested k. In R, with no
packages:

    tab <- read.csv("https://raw.githubusercontent.com/chrispbsmolen/ca-tools/main/table/ca_table.csv",
                    stringsAsFactors = FALSE)
    tab$N <- as.numeric(tab$N)
    best_known <- function(tab, t, v, k) {
        s <- tab[tab$tier %in% c("CITED", "VERIFIED") &
                 tab$t == t & tab$v == v & tab$k >= k, ]
        if (nrow(s) == 0) NA_real_ else min(s$N)
    }
    best_known(tab, 3, 13, 197)   # 6422 as of 2026-10-18 (Bergeron)

`ca_table.R` in this directory has `load_ca_table()` and the same
`best_known()`, and `ca_table.rda` is the table as an R data frame.
SCREENED rows are listed but excluded from best known on purpose. When
a screened array is later verified in full, it gets a new VERIFIED row
with that machine's stamp, the SCREENED row stays in the file, and the
page no longer shows it. Bergeron's three v = 19 arrays went this way
on 2026-10-21, from full checks run on 2026-10-18. The file is about
1.7 MB and grows by one row per accepted claim.

### In place of the frozen Colbourn tables (eCAN, eCAK)

`CAs::eCAN(t, k, v)` and `CAs::eCAK(t, N, v)` read the frozen
Colbourn tables in `CAs::colbournBigFrame` and return the best N for
at least k columns, or the most columns for at most N runs, with that
row's Source text. This table can stand in for them.
`tools/ecan_compare.R` checks it. Its output with CAs 0.24-4 is
kept in `../results/`, one file per run, the latest
`ecan_compare_2026-10-21b.txt`. The 13,641
CITED rows equal `colbournBigFrame` row for row, with `construction`
equal to its `Source`. The lookups below, run over the CITED rows
alone, reproduce eCAN and eCAK exactly, number and Source text, at
every one of the 13,641 points of the frozen tables. Run over the
CITED and VERIFIED rows together, as of 2026-10-21 they give a
smaller N at 24 of those points and more columns at 32, and never a
worse value. In R,
with `tab` read as above:

    eCAN_table <- function(tab, t, k, v) {
        s <- tab[tab$tier %in% c("CITED", "VERIFIED") &
                 tab$t == t & tab$v == v & tab$k >= k, ]
        if (nrow(s) == 0) return(data.frame(CAN = NA, Source = ""))
        i <- which.min(s$N)
        data.frame(CAN = s$N[i], Source = s$construction[i])
    }
    eCAK_table <- function(tab, t, N, v) {
        s <- tab[tab$tier %in% c("CITED", "VERIFIED") &
                 tab$t == t & tab$v == v & tab$N <= N, ]
        if (nrow(s) == 0) return(data.frame(CAK = NA, Source = ""))
        i <- which.max(s$k)
        data.frame(CAK = s$k[i], Source = s$construction[i])
    }

The functions name the tiers they count. If another tier is added to
the table later, it is documented here, and these lookups keep their
meaning until a caller chooses to count it.

The address above always serves the newest table, so the same call
can return a smaller N next month. For a result that can be repeated,
read the table at a fixed commit, for example

    https://raw.githubusercontent.com/chrispbsmolen/ca-tools/9494361e011d3b96645164032c3abe4fa7537c09/table/ca_table.csv

and report the commit with the result. The table is append-only in
its claims, so a fixed commit always reads the same. The newest
commit is listed at
https://api.github.com/repos/chrispbsmolen/ca-tools/commits/main
(field `sha`). For use without a network, `ca_table.rda` holds the
same table as an R data frame in about 80 KB and can travel inside a
package, refreshed at each release.

## Querying

    Rscript -e 'source("ca_table.R"); tab <- load_ca_table(); best_known(tab, 5, 3, 7)'
    python3 ca_table.py best 5 3 7
    python3 ca_table.py verified 5 3

Both return 351 for the first query, and the second shows the stamp:
that array is in `arrays/CA_351_5_7_3.txt`, its SHA-256 is in the
table, and you can re-verify it yourself in one line with the
caverify package.

## How to append a row (maintainer's guide)

The table is append-only in its claims: a row's t, v, k, N, tier,
source, hash, stamp and entry date are never changed, and a better N
or a correction is a new row. Four things have been written into
existing rows since publication, all recorded here: on 2026-10-19
the `construction` text of the 23 Bergeron rows was corrected to the
formula checked against all 23 arrays; on 2026-10-20 the new
`construction` column was filled for rows that predate it (above),
and the notes of the 23 Bergeron rows lost a fragment that repeated
the previous best; on 2026-10-21 the `construction` text of
the 24 CAEX rows was made precise (their last step is column
extension by computer search, per the `CAs::CAEX` help page, not a
product construction, which CAEX uses only for N = 34 and 36 to 50). To add a claim with evidence:

1. Get the array (download, construct, or receive it) and note the
   exact recipe: URL and date, or the generating call and package
   version, or the DOI.
2. Canonicalize: 0-based integer symbols, one run per line, space
   separated, newline endings. `verify_pipeline.R::canon_serialize`
   does this; `canon_sha256` hashes it.
3. Verify: `verify_claim(D, t, v, k, N, source_id, source_detail)`
   runs caverify at strength t and returns an append-ready row with
   the hash and stamp filled in. A failed check returns a
   FAILED_PENDING_RECHECK row; recheck from a fresh copy before
   concluding anything, catalogues go stale (see the log).
4. Append the row to `ca_table.csv`, never edit existing rows. A
   better N is a new row; a correction is a new row whose notes
   reference what it supersedes.
5. Regenerate `ca_table.rda` with `make_rda()`, and if you add the
   array to `arrays/`, add its MANIFEST.csv line.

Since 2026-10-18 the usual route is the submission check
(`../submissions/README.md`), which does steps 2 to 4 on a pull
request and fills `construction` from the claim.

### Admissible sources

Every row comes from a source that can be dated and fetched again or
derived again. The source classes are:

- S1, Colbourn's tables as preserved in `CAs::colbournBigFrame` (CAs
  0.24, snapshot `colbourn-2024-11-ug`), the baseline.
- S2, Ulrike Groemping's HTML mirror of the same tables, used only to
  cross-check S1. No rows.
- S3, Internet Archive captures of the original tables, each cited by
  its capture URL and date, used only to compare the tables' history.
  No rows.
- S4, the NIST covering array library, explicit arrays cited by exact
  URL.
- S5, the Dwyer CA_Database, explicit arrays cited by commit and path.
- S6, data and constructions of the CAs package, cited by package
  version and generating call.
- S7, the literature, cited by DOI or arXiv id (CITED, or VERIFIED
  when the paper or its supplement provides the array), and community
  submissions, explicit arrays verified by the submission check.

Not admissible: forums, unversioned personal pages, private
communications, anything that cannot be dated and fetched or derived
again. A new source class is added by a dated change to this list.

## Attribution

The baseline is the work of Charles J. Colbourn (the covering array
tables, 2005-2024) as preserved by Ulrike Groemping. Explicit arrays
come from the NIST covering array library (IPOG-F), the Dwyer
CA_Database (github.com/aadwyer/CA_Database), and the constructions
and data of the CAs R package (Groemping), and from community
submissions (S7), credited in each row, the first being Mickael
Bergeron's (github.com/MichelBacon/covering-arrays-rms-extension).
Verification stamps were produced with the caverify R package and,
for submissions, with `ca_verify.c` (both in this repository). The arrays
themselves are mathematical objects; each file's origin is in the
MANIFEST.
