#!/usr/bin/env python3
"""apply_construction_backfill - write table/construction_backfill.csv
(from tools/backfill_construction.R) into the construction column of
table/ca_table.csv, matching rows by array_sha256 and source_detail,
only where the column is empty. Every other byte of the table is left
as it is. Standard library only. Run from the repository root."""
import csv, io, os, sys
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
tab = os.path.join(REPO, "table", "ca_table.csv")
bf = os.path.join(REPO, "table", "construction_backfill.csv")
with open(bf, newline="", encoding="utf-8") as f:
    fill = {(r["array_sha256"], r["source_detail"]): r["construction"]
            for r in csv.DictReader(f) if r["construction"]}
with open(tab, newline="", encoding="utf-8") as f:
    rows = list(csv.reader(f))
h = rows[0]; ic, isha, isd = h.index("construction"), h.index("array_sha256"), h.index("source_detail")
n = 0
for r in rows[1:]:
    if not r[ic] and (r[isha], r[isd]) in fill:
        r[ic] = fill[(r[isha], r[isd])]; n += 1
buf = io.StringIO(); csv.writer(buf, lineterminator="\r\n").writerows(rows)
with open(tab, "w", encoding="utf-8", newline="") as f:
    f.write(buf.getvalue())
print("filled %d rows" % n)
