## Submission

cafast 0.1.0. First submission.

The package gives compiled implementations and generalizations of
selected functions of 'CAs' (Ulrike Groemping) for covering arrays:
`maxconstant_c()` (largest set of rows that can be made constant),
`powerCT_any()`, `power_plan()` and `power_build()` (the power
construction of Colbourn and Torres-Jimenez for any strength, number of
columns and number of levels), `count_core()` (tuple counts for every
set of t columns), and `flexpos_c()`, `markflex_c()` and
`postopNCK_c()` (flexible values and the post-optimization of Nayeri,
Colbourn and Konjevod).

## Test environments

* local: Ubuntu 24.04.5 LTS (container), x86_64-pc-linux-gnu, R 4.3.3
  (2024-02-29), gcc 13.3.0, `R CMD check --as-cran` on the tarball
  (md5 8375cb49e1b39efadc78ad03ac218720), 2026-10-17: Status 4 NOTEs.

## R CMD check results

0 errors | 0 warnings | 4 notes

      checking CRAN incoming feasibility ... NOTE
      Maintainer: 'Christopher Smolen <chrispbsmolen@gmail.com>'

      New submission

      Found the following (possibly) invalid URLs:
        URL: https://github.com/chrispbsmolen/ca-tools
          From: DESCRIPTION
          Status: 403
          Message: Forbidden
        URL: https://github.com/chrispbsmolen/ca-tools/issues
          From: DESCRIPTION
          Status: 403
          Message: Forbidden

This is a first submission. The 403 comes from the network proxy of
the test machine, which answers 403 for every github.com page. The
same URLs are in the DESCRIPTION of caverify, which is on CRAN.

      checking for future file timestamps ... NOTE
      unable to verify current time

The test machine could not reach the time server.

      checking compilation flags used ... NOTE
      Compilation used the following non-portable flag(s):
        '-mno-omit-leaf-frame-pointer'

The flag comes from the CFLAGS of the Ubuntu build of R on the test
machine, not from the package, which has no Makevars.

      checking HTML version of manual ... NOTE
      Skipping checking HTML validation: no command 'tidy' found
      Skipping checking math rendering: package 'V8' unavailable

Local tooling only. It does not arise on CRAN.

## Notes for the reviewer

The package does not use OpenMP. All C code is single threaded and
registered with `R_registerRoutines()` and `R_useDynamicSymbols()`.

'CAs' is in Imports because `power_plan()` and `power_build()` call
`CAs::SCA_Busht()` for the orthogonal array and, by default,
`CAs::bestCA()` for the ingredient. The examples and tests pass an
ingredient built with `CAs::KSK()`, so they need no network. Each
function was tested against its 'CAs' counterpart, and the help pages
state the differences that remain. The deliberate deviations of
`postopNCK_c()` from `CAs::postopNCK()` were agreed with the author of
'CAs'. The comparison batteries download arrays from the NIST tables
and are installed in `inst/tests`, outside `R CMD check`.
