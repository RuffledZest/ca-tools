# Reference results for the propagation engine

Fixed inputs and the engine's outputs on them, saved on 2026-10-21
before any change to the engine, so that every later change can be
checked against them byte for byte.

    sh r/livingtable/tests/run_reference.sh

runs from the repository root, works in a temporary copy of
`r/livingtable` (nothing tracked is written; every output file is
deleted in the copy before the run that should produce it), prints the
R and CAs versions, and ends with `REFERENCE CHECK: PASS` or `FAIL`.
It needs R and the CAs package; the frozen record is read from
`CAs::colbournBigFrame`. The references were recorded with R 4.3.3 and
CAs 0.24.4.

| check | input | expected |
|---|---|---|
| identity | the frozen record | `expected/identity.txt`: 4,425 of 4,425 RECURSIVE entries reproduced, and a freshly written `data/arith_edges.csv` identical to the one in the repository |
| september | `inputs/imp_september.csv`, the 17 verified improvements of September 2026 (`data/better_verified.csv`) | `expected/cascade_september.csv`, 2 entries; identical to the committed `data/arith_cascade.csv` |
| table | `inputs/imp_table_0cc536b.csv`, every VERIFIED row of `table/ca_table.csv` at commit 0cc536b, sorted by t, v, k, N and sha256, with its constant rows from the MANIFEST (1 where the array is not stored) | `expected/cascade_table.csv`, 2 entries, byte-identical to the September cascade: of the 561 rows, 60 beat the frozen record and only the 3381 at (3, 12, 14) moves anything |
| synthetic | `inputs/imp_synthetic.csv`, 15 invented improvements chosen to set off a long cascade | `expected/cascade_synthetic.csv`, 415 entries over 4 rounds |
| credit | `inputs/imp_credit.csv`, 3 invented improvements with one constant row each (build step 2c, saved on 2026-10-22) | `expected/cascade_credit.csv`, 6 entries: 4 power entries whose tags credit constant rows (`c`) and 2 direct products, each lookup of the improved arrays credited for the one constant row they carry; the third row is below the trivial bound v^t and must be rejected (2 of 3 accepted) |

For each propagation input the engine's working (`data/arith_chain_<input>.csv`,
added in build step 2b) must also equal `expected/chain_<name>.csv`, and
`check_chains.R` must recompute every changed value from its working:
the law of its family evaluated on the recorded values and constant-row
credits, no lookup missing and none extra, and for the direct product
the recorded pair checked by the law's own rule (2, 2, 415 and 6 entries).
It reads the engine's laws and data files and `CAs::colbournBigFrame`.

The credit input is the only one whose offered improvements carry fewer
than v constant rows, and the only one that reaches a power entry whose
tag credits constant rows. (The synthetic input already reaches the
direct product's credit through derived entries, each counted as one
constant row, beside frozen partners counted as one.) Its working
records 9 lookups credited for 1 constant row where the frozen record
credits v = 2 or 6. Each of the 6 changes was also worked by hand; for
example the power entry (5, 2, 4624), tag `Power CT68^2,c`, is
7 × (131 − 1) = 910, where crediting 2 constant rows would give 905,
and the direct product (2, 6, 600) is 57 + 57 − 2 = 112 from the pair
(24, 25), both answered by the improved 25-column array. In the power
entries (5, 2, 4896) and (5, 2, 5440) the credit does not change the
value: the leftover term χ of the hash law stays above zero there, and
a smaller credit lowers χ by exactly what it adds to the rest. So the
power credit is tested by (5, 2, 2380) and (5, 2, 4624). Altering a
recorded credit in `expected/chain_credit.csv` for one of those two (1
to 2 or to NA), or a direct product's credit or a partner's constant
rows, makes `check_chains.R` fail on that entry; this was tried when
the reference was recorded. The byte comparison with the expected
files catches any altered credit, including in the other two.

The perfect hash family entries whose tags credit constant rows are not
exercised: all 10 of them in the frozen record (tags ending in `,c`)
take their ingredient (t, w, v) at the trivial bound v^t, which no
improvement can beat, so that path cannot be reached by an accepted
improvement. The 18 `fuse` entries built from them use the fuse law,
which credits no constant rows. The third row of the credit input is
the nearest attempt on that path: if it were accepted, it would reach
one of those 10 entries, and the reference would fail.

The synthetic and credit inputs are test data only. Their sizes are not
claims about any array; one row of each deliberately cannot be accepted
(the synthetic one does not beat the table, the credit one is below the
trivial bound).

For each propagation input the two modes of the engine (graph and
sweep) must agree on the closure, and the summary lines (improvements
offered and accepted, entries changed and rounds in each mode) must
equal `expected/summary_<name>.txt`. `--record` rewrites the expected
files and is used only when a change to the engine's output is
intended, with the reason recorded in the commit. Every engine run must
exit with status 0.
