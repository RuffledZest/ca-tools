## Submission

caverify 0.2.0. Feature release. Mixed-level covering arrays (per-column
symbol counts), a corrected reading of missing values as flexible
entries, and a changed default for `v`. Full details in NEWS.md.

## Changes since 0.1.3

1. `v` accepts an integer vector giving each column its own number of
   symbols. Tuple counting in the C kernel is mixed-radix, and a uniform
   array is the degenerate case on the same code path.
2. An NA now marks a flexible ("don't care") entry. A row contributes
   nothing to a projection in which it has an NA, so a verified array is
   covering however its NA entries are later filled. In 0.1.x one NA
   counted as every symbol at once, per tuple independently, which could
   certify arrays that no single filling makes covering. This is a
   behaviour change and is documented as such. No released version
   combined the old NA reading with mixed-level support, since 0.1.x had
   no mixed-level support.
3. The default `v = NULL` now infers each column's symbol count from
   that column's own maximum. 0.1.x inferred one uniform value from the
   global data range, which misjudges mixed-level arrays. A scalar `v`
   behaves as before.

The reverse dependency 'CAs' (Ulrike Groemping) has been developed
against this version from GitHub and will require caverify >= 0.2.0;
its author asked for this release.

## Test environments

* local: macOS Tahoe 26.6.2, aarch64-apple-darwin23, R 4.6.1
  (2026-06-24), `R CMD check --as-cran` on the submitted tarball
  (md5 7c106ca58e82805348509ffd0c33c973), 2026-09-19: Status 1 NOTE.
* win-builder R-devel (2026-09-19 r90572 ucrt, gcc 14.3.0, Windows Server
  2022) on the same tarball, 2026-09-19: Status OK, no notes.

## R CMD check results

0 errors | 0 warnings | 1 note

      checking HTML version of manual ... NOTE
      Skipping checking HTML validation: 'tidy' doesn't look like recent
      enough HTML Tidy.
      Skipping checking math rendering: package 'V8' unavailable

Local tooling only. It does not arise on CRAN.

## Notes for the reviewer

The package uses OpenMP where it is available, guarded by
`SHLIB_OPENMP_CFLAGS` in `src/Makevars` and `src/Makevars.win`, and runs
single-threaded where it is not. Threads default to half the logical
cores, are capped at two when `_R_CHECK_LIMIT_CORES_` is set, and can be
overridden with `options(caverify.threads)`.

The tests include a brute-force oracle for mixed-level arrays, a
randomized cross-validation against an independent pure R
implementation, and a regression case for the NA reading.

## Previous submission record

0.1.2 submitted 2026-08-19, published 2026-08-20.
0.1.3 submitted 2026-08-23 (correction requested by the CRAN Team for
the fedora-clang flavour), published 2026-08-23.
