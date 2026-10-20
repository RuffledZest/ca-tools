#!/bin/sh
# na_reverify_2026-10-20.sh - re-verifies, with the corrected ca_verify
# (the don't-care rule of caverify 0.2.0, a row contributes nothing to a
# projection in which it has an NA), every array on file that contains
# NA cells. All of them were stamped by caverify 0.2.0, which already
# used that rule, so this run is a confirmation, recorded because the
# standalone verifier used the old rule until 2026-10-20. Run from the
# repository root on a machine with cores (about 15 minutes on 16):
#   sh results/na_reverify_2026-10-20.sh 2>&1 | tee results/na_reverify_2026-10-20.txt
cc -O3 -pthread -o ca_verify ca_verify.c || exit 1
for f in $(grep -l NA table/arrays/*.txt); do
  n=$(basename "$f" .txt)
  t=$(echo "$n" | cut -d_ -f3); v=$(echo "$n" | cut -d_ -f5 | cut -d. -f1)
  printf '%s ' "$n"; ./ca_verify "$f" "$t" "$v" 16 2>&1 | grep -m1 'VERIFIED\|NOT A'
done
echo "NA REVERIFY DONE"
