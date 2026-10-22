#!/bin/sh
# run_reference.sh - reruns the propagation engine on fixed inputs and compares
# its outputs with the saved references, byte for byte.
#
#   sh r/livingtable/tests/run_reference.sh            compare (exit 1 on any difference)
#   sh r/livingtable/tests/run_reference.sh --record   write the expected files (only when a
#                                                     change to the engine's output is intended,
#                                                     and recorded as such); a check that does
#                                                     not succeed writes nothing and fails
#
# Run from the repository root. The engine runs in a temporary copy of
# r/livingtable, so nothing tracked is written; every output file is deleted
# in the copy before the run that should produce it. What is checked:
#   identity      the engine reproduces every RECURSIVE entry of the frozen record
#                 (the line "identity: 4425 of 4425 ...") and writes a fresh
#                 data/arith_edges.csv identical to the one in the repository
#   september     the 17 verified improvements of September 2026
#                 (data/better_verified.csv): 2 entries change
#   table         every VERIFIED row of table/ca_table.csv at commit 0cc536b,
#                 sorted by t, v, k, N, sha256, with its constant rows: 2 entries change
#   synthetic     15 invented improvements chosen to set off a long cascade
#                 (inputs/imp_synthetic.csv): 14 accepted, 415 entries change over
#                 4 rounds; test input only, not claims about any array
# For each propagation input: the two modes must agree on the closure, the
# cascade file must equal expected/cascade_<name>.csv, and the summary lines
# (improvements offered and accepted, entries and rounds of each mode) must
# equal expected/summary_<name>.txt.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
LT=$(cd "$HERE/.." && pwd)
RECORD=0; [ "${1:-}" = "--record" ] && RECORD=1
command -v Rscript >/dev/null 2>&1 || { echo "Rscript not found"; echo "REFERENCE CHECK: FAIL"; exit 1; }
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cp -R "$LT" "$WORK/lt"
cd "$WORK/lt" || exit 2
rm -f data/arith_cascade_imp_*.csv
fail=0
sha() { (sha256sum "$1" 2>/dev/null || shasum -a 256 "$1") | cut -c1-64; }
Rscript -e 'cat("R", as.character(getRversion()), " CAs", as.character(packageVersion("CAs")), "\n")'

# identity
committed=$(sha "$LT/data/arith_edges.csv")
rm -f data/arith_edges.csv
Rscript arith_engine.R identity > "$WORK/identity.out" 2>&1
idline=$(grep "^identity:" "$WORK/identity.out" | sed 's/ (.*s)$//')
ok=1
echo "$idline" | grep -q "^identity: \([0-9]*\) of \1 RECURSIVE" || ok=0
if [ -f data/arith_edges.csv ]; then edges=$(sha data/arith_edges.csv); else edges="missing"; ok=0; fi
[ "$edges" = "$committed" ] || ok=0
printf '%s\nedges %s\n' "$idline" "$edges" > "$WORK/identity.txt"
if [ $RECORD = 1 ] && [ $ok = 1 ]; then cp "$WORK/identity.txt" "$HERE/expected/identity.txt"; fi
if [ $ok = 1 ] && [ -f "$HERE/expected/identity.txt" ] && cmp -s "$WORK/identity.txt" "$HERE/expected/identity.txt"; then
    echo "identity   PASS  ($idline)"
else
    echo "identity   FAIL"; cat "$WORK/identity.txt"; echo "edges in the repository $committed"; tail -3 "$WORK/identity.out"; fail=1
fi

for name in september table synthetic; do
    case $name in
        september) in=imp_september.csv ;;
        table) in=imp_table_0cc536b.csv ;;
        synthetic) in=imp_synthetic.csv ;;
    esac
    cp "$HERE/inputs/$in" "$WORK/lt/$in"
    out="data/arith_cascade_${in%.csv}.csv"
    rm -f "$out"
    Rscript arith_engine.R propagate "$in" > "$WORK/$name.out" 2>&1
    grep -E "^improvements offered:|^graph mode: [0-9]+ entries|^sweep mode: [0-9]+ entries" "$WORK/$name.out" \
        | sed 's/ (.*s)$//' > "$WORK/summary_$name.txt"
    agree=$(grep -c "TWO-MODE AGREEMENT ON THE CLOSURE: PASS" "$WORK/$name.out")
    ok=1; why=""
    [ "$agree" = 1 ] || { ok=0; why="the two modes do not agree"; }
    [ -f "$out" ] || { ok=0; why="no cascade file was written"; }
    [ "$(wc -l < "$WORK/summary_$name.txt")" -eq 3 ] || { ok=0; why="summary lines missing"; }
    if [ $RECORD = 1 ] && [ $ok = 1 ]; then
        cp "$out" "$HERE/expected/cascade_$name.csv"; cp "$WORK/summary_$name.txt" "$HERE/expected/summary_$name.txt"
    fi
    if [ $ok = 1 ]; then
        if [ ! -f "$HERE/expected/cascade_$name.csv" ] || [ ! -f "$HERE/expected/summary_$name.txt" ]; then
            ok=0; why="expected file missing"
        elif ! cmp -s "$out" "$HERE/expected/cascade_$name.csv"; then
            ok=0; why="cascade differs from expected/cascade_$name.csv"
        elif ! cmp -s "$WORK/summary_$name.txt" "$HERE/expected/summary_$name.txt"; then
            ok=0; why="summary differs from expected/summary_$name.txt"
        fi
    fi
    if [ $ok = 1 ]; then
        echo "$(printf '%-10s' $name) PASS  ($(($(wc -l < "$out") - 1)) entries change, two modes agree)"
    else
        echo "$(printf '%-10s' $name) FAIL  ($why)"; cat "$WORK/summary_$name.txt"; tail -3 "$WORK/$name.out"; fail=1
    fi
done

if [ $RECORD = 1 ]; then
    if [ $fail = 0 ]; then echo "expected files written"; else echo "nothing written for the checks that failed"; fi
fi
if [ $fail = 0 ]; then echo "REFERENCE CHECK: PASS"; else echo "REFERENCE CHECK: FAIL"; fi
exit $fail
