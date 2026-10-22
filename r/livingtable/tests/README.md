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

For each propagation input the engine's working (`data/arith_chain_<input>.csv`,
added in build step 2b) must also equal `expected/chain_<name>.csv`, and
`check_chains.R` must recompute every changed value from its working:
the law of its family evaluated on the recorded values and constant-row
credits, no lookup missing and none extra, and for the direct product
the recorded pair checked by the law's own rule (2, 2 and 415 entries).
It reads the engine's laws and data files and `CAs::colbournBigFrame`.
None of these inputs yet feeds an improved row with fewer than v
constant rows into a law that credits constant rows; a reference that
does is planned as its own step.

The synthetic input is test data only. Its sizes are not claims about
any array; one of its 15 rows deliberately does not beat the table and
must be rejected.

For each propagation input the two modes of the engine (graph and
sweep) must agree on the closure, and the summary lines (improvements
offered and accepted, entries changed and rounds in each mode) must
equal `expected/summary_<name>.txt`. `--record` rewrites the expected
files and is used only when a change to the engine's output is
intended, with the reason recorded in the commit. Every engine run must
exit with status 0.
