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
# in the copy before the run that should produce it. The engine and the chain
# checker read the base record from the baseline rows (CITED, S1) of table/ca_table.csv
# (base_record.R); CAs is needed only for the cross-check below. What is checked:
#   base          the baseline rows give the recorded fingerprint, and, when CAs is
#                 installed, so does CAs::colbournBigFrame
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
#   credit        3 invented improvements with one constant row each (inputs/imp_credit.csv),
#                 power entries tagged c and direct products are credited for the one
#                 constant row; the third row is below the trivial bound and rejected (2 accepted);
#                 6 entries change; test input only
#   ties          9 invented improvements in two groups of equal size, to check the
#                 canonical order: the row named in the working is the one with more
#                 constant rows, then the earlier priority date (entered when no
#                 priority_date; undated rows last), then the wider array, then the
#                 smaller id; each part decides at least one name; 8 entries change;
#                 test input only
# Every engine run must exit with status 0. For each propagation input: the
# two modes must agree on the closure, the
# cascade file must equal expected/cascade_<name>.csv, and the summary lines
# (improvements offered and accepted, entries and rounds of each mode) must
# equal expected/summary_<name>.txt. The working of every change
# (data/arith_chain_<input>.csv) must equal expected/chain_<name>.csv, and
# tests/check_chains.R must recompute every value from its working alone.
# Each input is then run again with its rows in another order (a fixed
# shuffle); the cascade, working and summary must be the same files.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
LT=$(cd "$HERE/.." && pwd)
TABLE="$(cd "$LT/../.." && pwd)/table/ca_table.csv"
RECORD=0; [ "${1:-}" = "--record" ] && RECORD=1
command -v Rscript >/dev/null 2>&1 || { echo "Rscript not found"; echo "REFERENCE CHECK: FAIL"; exit 1; }
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cp -R "$LT" "$WORK/lt"
cd "$WORK/lt" || exit 2
rm -f data/arith_cascade_imp_*.csv data/arith_chain_imp_*.csv
fail=0
sha() { (sha256sum "$1" 2>/dev/null || shasum -a 256 "$1") | cut -c1-64; }
Rscript -e 'cat("R", as.character(getRversion()), " CAs", if (requireNamespace("CAs", quietly = TRUE)) as.character(packageVersion("CAs")) else "not installed", "\n")'

# base: the table's baseline rows (CITED, S1) are the calibrated record (base_record.R), and, when
# CAs is installed, the fingerprint of CAs::colbournBigFrame is the recorded one too
Rscript -e 'source("base_record.R"); r <- read_base(commandArgs(TRUE)[1])
    cat("table fingerprint", r$fp, if (r$ok) "matches" else paste("REFUSED:", r$why), "\n")
    ca <- if (requireNamespace("CAs", quietly = TRUE)) { e <- new.env(); data("colbournBigFrame", package = "CAs", envir = e); b <- e$colbournBigFrame
        base_fingerprint(b$t, b$v, b$k, b$N, b$Source) } else NA
    cat("CAs::colbournBigFrame fingerprint", if (is.na(ca)) "not checked (CAs not installed)" else ca, "\n")
    quit(save = "no", status = if (r$ok && (is.na(ca) || ca == BASE_FINGERPRINT)) 0 else 1)' "$TABLE" > "$WORK/base.out" 2>&1
if [ $? = 0 ]; then echo "base       PASS  ($(head -1 "$WORK/base.out" | cut -d' ' -f3)$(grep -q 'not checked' "$WORK/base.out" && echo ', CAs cross-check skipped' || echo ', equal to CAs::colbournBigFrame'))"
else echo "base       FAIL"; cat "$WORK/base.out"; fail=1; fi

# identity
committed=$(sha "$LT/data/arith_edges.csv")
rm -f data/arith_edges.csv
Rscript arith_engine.R identity --table="$TABLE" > "$WORK/identity.out" 2>&1; st=$?
idline=$(grep "^identity:" "$WORK/identity.out" | sed 's/ (.*s)$//')
ok=1
echo "$idline" | grep -q "^identity: \([0-9]*\) of \1 RECURSIVE" || ok=0
if [ -f data/arith_edges.csv ]; then edges=$(sha data/arith_edges.csv); else edges="missing"; ok=0; fi
[ "$edges" = "$committed" ] || ok=0
[ $st = 0 ] || ok=0
why=""
[ $st = 0 ] || why="the engine exited with status $st"
[ -n "$why" ] || [ "$edges" != "missing" ] || why="no edges file was written"
[ -n "$why" ] || [ "$edges" = "$committed" ] || why="the edges file differs from the repository"
[ -n "$why" ] || echo "$idline" | grep -q "^identity: \([0-9]*\) of \1 RECURSIVE" || why="not every entry was reproduced"
printf '%s\nedges %s\n' "$idline" "$edges" > "$WORK/identity.txt"
if [ $RECORD = 1 ] && [ $ok = 1 ]; then cp "$WORK/identity.txt" "$HERE/expected/identity.txt"; fi
if [ $ok = 1 ] && [ -f "$HERE/expected/identity.txt" ] && cmp -s "$WORK/identity.txt" "$HERE/expected/identity.txt"; then
    echo "identity   PASS  ($idline)"
else
    echo "identity   FAIL  (${why:-identity.txt differs from expected/identity.txt})"; cat "$WORK/identity.txt"; echo "edges in the repository $committed"; tail -3 "$WORK/identity.out"; fail=1
fi

for name in september table synthetic credit ties; do
    case $name in
        september) in=imp_september.csv ;;
        table) in=imp_table_0cc536b.csv ;;
        synthetic) in=imp_synthetic.csv ;;
        credit) in=imp_credit.csv ;;
        ties) in=imp_ties.csv ;;
    esac
    cp "$HERE/inputs/$in" "$WORK/lt/$in"
    out="data/arith_cascade_${in%.csv}.csv"
    chn="data/arith_chain_${in%.csv}.csv"
    rm -f "$out" "$chn"
    Rscript arith_engine.R propagate "$in" --table="$TABLE" > "$WORK/$name.out" 2>&1; st=$?
    grep -E "^improvements offered:|^graph mode: [0-9]+ entries|^sweep mode: [0-9]+ entries" "$WORK/$name.out" \
        | sed 's/ (.*s)$//' > "$WORK/summary_$name.txt"
    agree=$(grep -c "TWO-MODE AGREEMENT ON THE CLOSURE: PASS" "$WORK/$name.out")
    ok=1; why=""
    # the first reason found is the one reported; the exit status comes first
    [ $st = 0 ] || { ok=0; why="the engine exited with status $st"; }
    [ -n "$why" ] || [ "$agree" = 1 ] || { ok=0; why="the two modes do not agree"; }
    [ -n "$why" ] || [ -f "$out" ] || { ok=0; why="no cascade file was written"; }
    [ -n "$why" ] || [ "$(wc -l < "$WORK/summary_$name.txt")" -eq 3 ] || { ok=0; why="summary lines missing"; }
    [ -n "$why" ] || [ -f "$chn" ] || { ok=0; why="no chain file was written"; }
    [ -n "$why" ] || Rscript "$HERE/check_chains.R" "$chn" --table="$TABLE" > "$WORK/chaincheck_$name.out" 2>&1 || { ok=0; why="a chain does not recompute to its value (check_chains.R)"; }
    # this run's files are kept aside; in --record mode they are written to expected/ only
    # after every check below has passed, the run in another order included
    if [ $ok = 1 ]; then cp "$out" "$WORK/first_cascade_$name.csv"; cp "$chn" "$WORK/first_chain_$name.csv"; fi
    if [ $ok = 1 ] && [ $RECORD = 0 ]; then
        if [ ! -f "$HERE/expected/cascade_$name.csv" ] || [ ! -f "$HERE/expected/summary_$name.txt" ] || [ ! -f "$HERE/expected/chain_$name.csv" ]; then
            ok=0; why="expected file missing"
        elif ! cmp -s "$out" "$HERE/expected/cascade_$name.csv"; then
            ok=0; why="cascade differs from expected/cascade_$name.csv"
        elif ! cmp -s "$WORK/summary_$name.txt" "$HERE/expected/summary_$name.txt"; then
            ok=0; why="summary differs from expected/summary_$name.txt"
        elif ! cmp -s "$chn" "$HERE/expected/chain_$name.csv"; then
            ok=0; why="working differs from expected/chain_$name.csv"
        fi
    fi
    # the same input in another order must give the same files (canonical order)
    if [ $ok = 1 ]; then
        mkdir -p shuf
        Rscript -e 'a <- commandArgs(TRUE); x <- readLines(a[1]); set.seed(20261023); writeLines(c(x[1], x[-1][sample(length(x) - 1)]), a[2])' "$HERE/inputs/$in" "shuf/$in"
        rm -f "$out" "$chn"
        Rscript arith_engine.R propagate "shuf/$in" --table="$TABLE" > "$WORK/${name}_shuf.out" 2>&1; st=$?
        grep -E "^improvements offered:|^graph mode: [0-9]+ entries|^sweep mode: [0-9]+ entries" "$WORK/${name}_shuf.out" \
            | sed 's/ (.*s)$//' > "$WORK/summary_${name}_shuf.txt"
        if [ $st != 0 ] || ! cmp -s "$out" "$WORK/first_cascade_$name.csv" || ! cmp -s "$chn" "$WORK/first_chain_$name.csv" \
            || ! cmp -s "$WORK/summary_${name}_shuf.txt" "$WORK/summary_$name.txt"; then
            ok=0; why="the input in another order gives different output"
        fi
    fi
    if [ $RECORD = 1 ] && [ $ok = 1 ]; then
        cp "$WORK/first_cascade_$name.csv" "$HERE/expected/cascade_$name.csv"; cp "$WORK/summary_$name.txt" "$HERE/expected/summary_$name.txt"
        cp "$WORK/first_chain_$name.csv" "$HERE/expected/chain_$name.csv"
    fi
    if [ $ok = 1 ]; then
        echo "$(printf '%-10s' $name) PASS  ($(($(wc -l < "$out") - 1)) entries change, two modes agree, every working recomputes, same in another order)"
    else
        echo "$(printf '%-10s' $name) FAIL  ($why)"; cat "$WORK/summary_$name.txt"; tail -3 "$WORK/$name.out"; fail=1
    fi
done

if [ $RECORD = 1 ]; then
    if [ $fail = 0 ]; then echo "expected files written"; else echo "nothing written for the checks that failed"; fi
fi
if [ $fail = 0 ]; then echo "REFERENCE CHECK: PASS"; else echo "REFERENCE CHECK: FAIL"; fi
exit $fail
