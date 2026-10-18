# cafast CRAN preparation, 2026-10-17

Package source: /home/claude/cafast_work/cafast. Tarball checked:
/home/claude/cafast_work/cafast_0.1.0.tar.gz (md5
8375cb49e1b39efadc78ad03ac218720). Check log:
/home/claude/cafast_work/check_cafast.log. Result of `R CMD check
--as-cran` with R 4.3.3 on Ubuntu 24.04.5: 0 errors, 0 warnings, 4 NOTEs,
all environment noise (listed below).

## Changes, file by file

- man/ (new, written by hand, roxygen2 is not installed here). One page
  per exported function or family: maxconstant_c.Rd, count_core.Rd,
  flexpos_c.Rd (flexpos_c and markflex_c), postopNCK_c.Rd,
  powerCT_any.Rd (powerCT_any, power_plan, power_build), and
  cafast-package.Rd. Usage lines copy the R defaults exactly (codoc
  passes). Each page names the CAs function it reimplements and the
  differences: the clique tie-break and the NA rules for maxconstant_c,
  the input handling for flexpos_c and markflex_c, the deviations
  D3 to D8 from R/nck_driver.R for postopNCK_c, the homogeneous-only
  scope for the power functions. Examples run offline in about 2 s in
  total, most of it loading CAs. They use the 14-run array from the
  CAs::markflex examples, an OA(64, 4, 4, 3) built inline with three NA
  cells, and an ingredient from CAs::KSK, so no \donttest is needed and
  nothing is downloaded.
- R/maxconstant_c.R. Accepts NA cells (rule below). The stop() on NA is
  replaced by a stop() for a row made only of NA cells. Constant rows
  are detected NA-safely. In the one_is_enough branch NA cells of row 1
  are skipped. NA cells of the clique rows are filled before the symbol
  permutation. NA-free behaviour is unchanged (the 52 old battery cases
  give the same results).
- src/mc_core.c. disjoint() skips a column in which either cell is
  NA_INTEGER, so an NA matches nothing. Comment updated. No other C
  change. All four C files compile without warnings under -Wall. With
  -Wextra the only warnings are -Wcast-function-type on the DL_FUNC
  casts in src/init.c, the standard registration idiom.
  src/init.c already calls R_registerRoutines and
  R_useDynamicSymbols(dll, FALSE). No Makevars is needed.
- inst/tests/test_maxconstant.R. nconst() and ntotal() made NA-safe
  (identical on NA-free arrays). Added 82 NA cases compared with
  CAs::maxconstant (details below) and two printed known-difference
  cases. The other files in inst/tests are untouched.
- DESCRIPTION. caverify style: Authors@R, Title "Fast Companions to the
  'CAs' Package for Covering Arrays" (56 characters), Description naming
  'CAs' in quotes with the two DOIs, License MIT + file LICENSE, URL,
  BugReports, Encoding UTF-8, Language en-US, NeedsCompilation yes.
  Depends R (>= 4.0) kept. Imports: CAs (the R code calls
  CAs::SCA_Busht and CAs::bestCA). Suggests: caverify, lhs (used only by
  the inst/tests batteries). No R file calls caverify::, lhs::, igraph::,
  library() or requireNamespace().
- LICENSE (new). Copied from caverify_ref: "YEAR: 2026" and
  "COPYRIGHT HOLDER: Christopher Smolen".
- NAMESPACE. Removed importFrom(stats, runif) and importFrom(utils,
  combn). Neither function is used in R/, and keeping them would have
  required stats and utils in Imports.
- NEWS.md (new), 0.1.0 entry.
- .Rbuildignore (new): NOTES.md, cran-comments.md and README.md stay out
  of the tarball. README.md says "Working name: rename at will" and
  gives build paths for the ca-tools tree, which CRAN would show on the
  package page. Remove that line from .Rbuildignore if a README is
  wanted on CRAN after editing it.
- tests/test-cafast.R (new). Plain R, about 3 s, no network. It checks
  every exported function on inline arrays with fixed expected values
  (count_core on 2^3 and an OA(4, 3, 2, 2), maxconstant_c on the 14-run
  array including remove and one_is_enough and on the OA(64, 4, 4, 3)
  with NA cells, flexpos_c counts and conventions, markflex_c row order
  and flex counts, postopNCK_c with seed 1 giving 12 rows that still
  cover, power_plan, powerCT_any and power_build with the KSK
  ingredient, coverage checked with count_core). Comparisons with CAs
  sit under requireNamespace("CAs", quietly = TRUE). The NA comparison
  also needs CAs >= 0.24-4, because CRAN has CAs 0.24-3, which fails on
  NA cells in clique rows (verified here by installing 0.24-3 from CRAN
  into a separate library: the script passes with both versions).
- NOTES.md. New section "NA cells in maxconstant_c, CRAN preparation
  (2026-10-17)". The old line "NA cells are refused" in section 1 is
  left as history.
- cran-comments.md (new), caverify style.

Container changes made for the check (not package changes): generated
the en_US.UTF-8 locale and installed texlive-fonts-extra. Without them
the check gave two WARNINGs (locale cannot be set for the R syntax
check, inconsolata.sty missing for the PDF manual).

## NA semantics implemented in maxconstant_c

Read from /home/claude/casrc/CAs/R/maxconstant.R (CAs 0.24-4) and
confirmed by running both functions.

1. Existing constant rows. A row is constant only if it has no NA cell
   and all its cells are equal. (Hers: length(unique(row)) == 1, so a
   row with an NA has at least two distinct values.) A row made only of
   NA cells is an error in ours.
2. Graph. Rows i and j are adjacent if and only if D[i, c] != D[j, c]
   for every column c in which both are non-missing. An NA cell matches
   nothing. (Hers: min(abs(D[i, ] - D[j, ]), na.rm = TRUE) > 0, with
   Inf > 0 when every comparison is NA.)
3. Clique choice. Unchanged: a clique containing the existing constant
   rows is preferred unless a strictly larger one exists. The search
   stops at v rows.
4. Fill. With remove = FALSE and a clique larger than the existing
   constant rows, the clique rows move to the front, and in each column
   the NA cells among them are filled from the top with
   setdiff(levs, clique values in that column) in ascending order,
   where levs are the sorted levels of the array. (Hers uses
   setdiff(0:(v-1), ...), identical for 0-based coding.)
5. Permutation. The symbols of each column are then permuted so the
   clique rows become levs[1], levs[2], ... NA cells outside the clique
   stay NA.
6. one_is_enough = TRUE with no constant row. Row 1 is made constant by
   swaps in the columns where it has a symbol. Its NA cells stay NA, as
   in hers.

Battery result (inst/tests/test_maxconstant.R, run here): 134 cases, 0
mismatches. 52 old cases unchanged. 82 NA cases: the 40 random cases
with 4 percent of cells blanked (keeping all levels in each column, as
her symmetry check requires), 20 random arrays without a planted
clique, 20 random cases with 25 percent of the cells of the planted
constant rows blanked, Bush CA(4,5,4) with NAs inside its clique rows
and with 3 percent NAs elsewhere. Same number of leading constant rows
in 77 cases, and our result is equivalent to the input in all 82 (rows
reordered, a bijection of symbols on the non-missing cells of each
column, NA kept outside the clique and filled inside it).

What differs, and is not counted as a mismatch:

- In 5 NA cases (random13+NA, random17+NA, random28+NA, random39+NA,
  random4+NAclique, all with 3 columns) her igraph clique has v + 1
  rows, possible only because NA cells make an extra row compatible. No
  filling makes more than v rows constant. Her fill then cannot supply
  enough levels, and she returns 0 or 1 constant rows with
  non-equivalent output (her symbols no longer form a bijection). Ours
  returns v constant rows. The test classifies these as "her clique >
  v" and requires ours to give v rows and an equivalent array.
- Only one constant row possible, none constant, NA in row 1: hers
  stops with "argument of length 0" (hilf becomes a vector when the
  clique has one row), ours fills the cell. Printed in the test.
- Levels: ours from the whole array, hers from column 1, and she stops
  unless every column has the same number of levels (unchanged from
  before).

These are failures or limits on her side, not ambiguities in the rule,
so the NA support was kept rather than reverting to stop(). If you would
rather match her output exactly in the first case, there is no output
to match: no array of the required form exists.

Full battery rerun here after the change (run_all.sh against the
installed package, R 4.3.3, CAs 0.24-4):
/home/claude/cafast_work/run_all_result_container_2026-10-17.txt.
count_core 529 cases 0 failures. nck faces all pass. maxconstant 134
cases 0 mismatches (hers 65.1 s, ours 0.6 s). powerct 0 failures. nck
driver all pass. Note: the file inst/tests/run_all_result_2026-10-17.txt
named in the brief was not in this copy of the package. Only the
scripts were there.

## Remaining NOTEs (all environment noise)

1. CRAN incoming feasibility: "New submission" (expected) and the URLs
   https://github.com/chrispbsmolen/ca-tools and .../issues reported
   with status 403. The container proxy answers 403 for every
   github.com page (github.com/ugroempi/CAs also gives 403 here). I
   could not confirm from here that the repository is public. The same
   URLs are in caverify's DESCRIPTION on CRAN.
2. "checking for future file timestamps ... unable to verify current
   time". The container cannot reach the time service.
3. "Compilation used the following non-portable flag(s):
   '-mno-omit-leaf-frame-pointer'". It comes from CFLAGS in the
   Ubuntu build of R (etc/Makeconf), not from the package.
4. "checking HTML version of manual": no 'tidy' command and no V8
   package here. The same NOTE is in caverify's cran-comments.

## Points for the author to decide

- Licence. The package was GPL (>= 2) and is now MIT as the brief
  asked. CAs is GPL-3. Several files follow her code closely (comments
  say power_assemble "mirrors CAs::DHHF2CA", nck_driver.R is "the
  algorithm as implemented in CAs::postopNCK (read at source)"). Whether
  that makes them derived works under GPL-3 is a question to settle,
  for example by asking her, before releasing them under MIT.
- CAs on CRAN is 0.24-3 (checked today). It exports SCA_Busht, bestCA
  and KSK, so Imports: CAs works against CRAN. Its maxconstant lacks
  the NA fix. When 0.24-4 reaches CRAN, nothing has to change here.
- power_plan with the default ingredient calls CAs::bestCA, which uses
  the NIST tables when a connection exists. The help page says so.

## Still to do on the Mac

1. Copy the changed files into ca-tools/r/cafast (DESCRIPTION, LICENSE,
   NAMESPACE, NEWS.md, .Rbuildignore, cran-comments.md, NOTES.md,
   R/maxconstant_c.R, src/mc_core.c, man/, tests/,
   inst/tests/test_maxconstant.R), then rerun
   inst/tests/run_all.sh and save the result file.
2. R CMD build and R CMD check --as-cran on R 4.6.1 with the current
   CRAN CAs 0.24-3 installed as well as with 0.24-4, and update the
   Test environments section of cran-comments.md with the tarball md5
   and the status.
3. Confirm github.com/chrispbsmolen/ca-tools is public and has issues
   enabled, so the URL NOTE disappears.
4. devtools::check_win_devel() or upload to win-builder (R-devel), and
   optionally R-release. Add the results to cran-comments.md.
5. Submit at https://cran.r-project.org/submit.html with the tarball,
   confirm the email from CRAN.
