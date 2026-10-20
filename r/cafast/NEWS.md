# cafast 0.1.1 (development, after the 0.1.0 CRAN submission)

* `maxconstant_c()` no longer counts a duplicated constant row twice.
  With `v` rows already constant it returned them without checking that
  they were `v` distinct constants, so an array holding two copies of
  the all-zero row and one all-one row was reported as having 3
  constant rows at v = 3. Found 2026-10-20 by differential testing
  against the standalone `constant_rows` program in ca-tools.
  `CAs::maxconstant()` has the same shortcut.

# cafast 0.1.0

First release.

* `maxconstant_c()`, a C implementation of `CAs::maxconstant()`. Arrays
  with `NA` cells are accepted and treated as in the current
  `CAs::maxconstant()` (version 0.24-4): an `NA` cell matches no symbol
  when rows are compared, and the `NA` cells of the rows made constant
  are filled.
* `powerCT_any()`, `power_plan()` and `power_build()`, the power
  construction of Colbourn and Torres-Jimenez for any strength, number
  of columns and number of levels, homogeneous case.
* `count_core()`, tuple counts for every set of t columns.
* `flexpos_c()`, `markflex_c()` and `postopNCK_c()`, C versions of
  `CAs::flexpos()`, `CAs::markflex()` and of the marking steps of
  `CAs::postopNCK()`.
