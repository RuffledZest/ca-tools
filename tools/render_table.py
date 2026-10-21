#!/usr/bin/env python3
"""render_table - write the static table page (docs/index.html).

Reads table/ca_table.csv and table/MANIFEST.csv and writes one plain
HTML page: what the table is, counts of verified and screened arrays,
the community submissions with their credit, and for every (t, v) the
current best known N as a stair-step, each rung marked with its
evidence (verified rows with their stamp and credit). No JavaScript.
Standard library only.

Usage: render_table.py [--table-dir table] [--out docs/index.html] [--date YYYY-MM-DD]
"""
import argparse
import collections
import csv
import datetime
import html
import os
import re

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO_URL = "https://github.com/chrispbsmolen/ca-tools"
RAW_CSV = "https://raw.githubusercontent.com/chrispbsmolen/ca-tools/main/table/ca_table.csv"

CSS = """
:root { color-scheme: light dark; --fg:#1d1d1f; --bg:#fdfdfc; --mute:#5f6368;
  --line:#dcdcd8; --ver:#0b6e3a; --scr:#8a5a00; --soft:#f2f2ee; }
@media (prefers-color-scheme: dark) { :root { --fg:#e8e8e3; --bg:#18181a;
  --mute:#a0a0a0; --line:#3a3a3d; --ver:#5fd08f; --scr:#e0b050; --soft:#232326; } }
* { box-sizing: border-box; }
body { margin:0; background:var(--bg); color:var(--fg);
  font:16px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; }
main { max-width: 52rem; margin: 0 auto; padding: 1.5rem 16px 4rem; }
h1 { font-size: 1.6rem; line-height:1.25; margin: 0 0 .5rem; }
h2 { font-size: 1.2rem; margin: 2rem 0 .5rem; border-bottom: 1px solid var(--line); padding-bottom:.25rem; }
p, li { overflow-wrap: anywhere; }
.mute { color: var(--mute); font-size: .9rem; }
.stats { display:flex; flex-wrap:wrap; gap:.5rem; margin:1rem 0; padding:0; list-style:none; }
.stats li { background:var(--soft); border-radius:6px; padding:.4rem .7rem; }
.stats b { font-variant-numeric: tabular-nums; }
table { border-collapse: collapse; width:100%; font-size:.9rem; margin:.5rem 0 1rem; }
th, td { text-align:left; vertical-align:top; padding:.3rem .4rem; border-bottom:1px solid var(--line); }
td.n, th.n { text-align:right; font-variant-numeric: tabular-nums; white-space:nowrap; }
td.ev { overflow-wrap:anywhere; }
details { border-bottom:1px solid var(--line); padding:.35rem 0; }
summary { cursor:pointer; }
.tag { display:inline-block; font-size:.75rem; font-weight:600; border-radius:4px; padding:0 .35rem;
  border:1px solid currentColor; margin-right:.3rem; }
.ver { color:var(--ver); } .scr { color:var(--scr); }
.stamp { color:var(--mute); font-size:.8rem; display:block; }
.subhead { font-size:.9rem; margin:.4rem 0; overflow-wrap:anywhere; }
.lbl { color:var(--mute); font-size:.8rem; margin-right:.3rem; }
details.sub > summary { padding:.15rem 0; }
a { color: inherit; }
@media (max-width: 480px) { body { font-size:15px; } table { font-size:.82rem; } th, td { padding:.25rem .2rem; } }
"""


def load(table_dir):
    with open(os.path.join(table_dir, "ca_table.csv"), newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    with open(os.path.join(table_dir, "MANIFEST.csv"), newline="", encoding="utf-8") as f:
        manifest = list(csv.DictReader(f))
    for r in rows:
        r["t"], r["v"], r["k"] = int(r["t"]), int(r["v"]), int(r["k"])
        r["N"] = int(float(r["N"]))
    return rows, manifest


def credit_of(r):
    m = re.search(r"credit: ([^;]*)", r.get("notes") or "")
    return m.group(1).strip() if m else ""


CR = {}


def constant_rows_of(r):
    c = CR.get(r.get("array_sha256") or "", "")
    return ("constant rows %s of %s" % (c, r["v"])) if c not in ("", None) else ""


def construction_of(r):
    """The construction column; for rows that predate it, the source_detail
    of a CITED row is Colbourn's construction label."""
    c = (r.get("construction") or "").strip()
    if not c and r.get("tier") == "CITED":
        c = (r.get("source_detail") or "").strip()
    return c


def slug_of(r):
    m = re.search(r"submission ([A-Za-z0-9._-]+)", r.get("notes") or "")
    return m.group(1) if m else "(unnamed)"


def submissions_html(subs):
    """One folded <details> per submission. Text that is the same for every
    array of a submission (credit, construction, stamp, entry date) is shown
    once above its table; text that differs stays in a column."""
    out = []
    groups = collections.OrderedDict()
    for r in sorted(subs, key=lambda r: (r["entered"], slug_of(r), r["t"], r["v"], r["k"]),
                    reverse=True):
        groups.setdefault(slug_of(r), []).append(r)
    shared_fields = (("credit", credit_of), ("construction", construction_of),
                     ("stamp", lambda r: r["verify_stamp"]), ("entered", lambda r: r["entered"]))
    for slug, rs in groups.items():
        rs = sorted(rs, key=lambda r: (r["t"], r["v"], r["k"]))
        nver = sum(1 for r in rs if r["tier"] == "VERIFIED")
        nscr = len(rs) - nver
        vs = sorted({r["v"] for r in rs}); ts = sorted({r["t"] for r in rs})
        span = lambda xs: str(xs[0]) if len(xs) == 1 else "%d to %d" % (xs[0], xs[-1])
        uniform = {name: len({f(r) for r in rs}) == 1 for name, f in shared_fields}
        # stamp and entry date: the most common value is shown once, and a
        # row with a different one carries it under its status, so a few
        # later checks do not add wide columns
        common = {}
        for name, f in shared_fields:
            if name in ("stamp", "entered") and not uniform[name]:
                common[name] = collections.Counter(f(r) for r in rs).most_common(1)[0][0]
        credits = sorted({credit_of(r) for r in rs})
        out.append("<details class=sub><summary><b>%s</b>, %s: %d array%s (%s), t = %s, "
                   "v = %s, entered %s</summary>" % (
                       html.escape(", ".join(credits)), html.escape(slug), len(rs),
                       "" if len(rs) == 1 else "s",
                       ", ".join(x for x in ("%d verified" % nver if nver else "",
                                             "%d screened" % nscr if nscr else "") if x),
                       span(ts), span(vs), html.escape(min(r["entered"] for r in rs))))
        lines = []
        for name, f in shared_fields:
            if uniform[name] and f(rs[0]):
                lines.append("<span class=lbl>%s</span> %s" % (name, html.escape(f(rs[0]))))
            elif name in common:
                n = sum(1 for r in rs if f(r) == common[name])
                lines.append("<span class=lbl>%s</span> %s (%d of %d arrays, the others noted "
                             "in their rows)" % (name, html.escape(common[name]), n, len(rs)))
        if lines:
            out.append("<p class=subhead>%s</p>" % "<br>".join(lines))
        cols = [name for name, _ in shared_fields if not uniform[name] and name not in common]
        out.append("<table><thead><tr><th class=n>t</th><th class=n>v</th><th class=n>k</th>"
                   "<th class=n>N</th><th class=n>prev. best</th><th class=n>const. rows</th>"
                   "<th>status</th>%s</tr></thead><tbody>"
                   % "".join("<th>%s</th>" % c for c in cols))
        for r in rs:
            prev = re.search(r"previous best (\d+)", r["notes"])
            c = CR.get(r.get("array_sha256") or "", "")
            tag = ('<span class="tag ver">verified</span>' if r["tier"] == "VERIFIED"
                   else '<span class="tag scr">screened</span>')
            extra = "".join("<td class=ev>%s</td>" % html.escape(f(r))
                            for name, f in shared_fields if name in cols)
            note = "".join("<span class=stamp>%s %s</span>" % (name, html.escape(f(r)))
                           for name, f in shared_fields
                           if name in common and f(r) != common[name])
            tag = tag + note
            out.append("<tr><td class=n>%d</td><td class=n>%d</td><td class=n>%d</td>"
                       "<td class=n>%d</td><td class=n>%s</td><td class=n>%s</td><td>%s</td>%s</tr>"
                       % (r["t"], r["v"], r["k"], r["N"], prev.group(1) if prev else "",
                          ("%s of %d" % (c, r["v"])) if c not in ("", None) else "", tag, extra))
        out.append("</tbody></table></details>")
    return out


def stair(rows_tv):
    """Rungs (N, k_from, k_to, evidence rows) from CITED and VERIFIED rows."""
    ev = [r for r in rows_tv if r["tier"] in ("CITED", "VERIFIED")]
    pairs = sorted({(r["N"], r["k"]) for r in ev})
    rungs, bestk = [], (rows_tv[0]["t"] - 1 if rows_tv else 0)
    for n, k in pairs:
        if k > bestk:
            rungs.append([n, bestk + 1, k])
            bestk = k
    out = []
    for n, k0, k1 in rungs:
        rs = [r for r in ev if r["N"] == n and r["k"] == k1]
        out.append((n, k0, k1, rs))
    return out


def evidence_html(rs):
    ver = [r for r in rs if r["tier"] == "VERIFIED"]
    parts = []
    if ver:
        r = ver[-1]
        cr = credit_of(r)
        con = construction_of(r)
        crs = constant_rows_of(r)
        parts.append('<span class="tag ver">verified</span>%s%s%s'
                     '<span class="stamp">%s, sha256 %s%s</span>' % (
                         html.escape(cr + "; ") if cr else "",
                         ("<i>%s</i>; " % html.escape(con)) if con else "",
                         html.escape(r["source_detail"]),
                         html.escape(r["verify_stamp"]), html.escape(r["array_sha256"][:12]),
                         (", " + crs) if crs else ""))
    else:
        r = rs[0]
        parts.append(html.escape(construction_of(r) or r["source_detail"] or r["source_id"]))
    return "".join(parts)


def render(rows, manifest, date):
    global CR
    CR = {m["sha256"]: m.get("constant_rows", "") for m in manifest}
    # a SCREENED row whose array was later verified in full (a VERIFIED row
    # with the same hash) is superseded: kept in the table, not shown
    verified_sha = {r["array_sha256"] for r in rows if r["tier"] == "VERIFIED" and r["array_sha256"]}
    rows_shown = [r for r in rows if not (r["tier"] == "SCREENED" and r["array_sha256"] in verified_sha)]
    tiers = collections.Counter(r["tier"] for r in rows_shown)
    mstat = collections.Counter(m["status"] for m in manifest)
    subs = [r for r in rows_shown if r["source_id"] == "S7" and r["tier"] in ("VERIFIED", "SCREENED")]
    by_tv = collections.defaultdict(list)
    for r in rows:
        by_tv[(r["t"], r["v"])].append(r)

    H = []
    H.append("<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
             "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
             "<title>Covering Array Table</title><style>%s</style></head><body><main>" % CSS)
    H.append("<h1>Best known covering arrays, with evidence</h1>")
    H.append("<p>A covering array CA(N; t, k, v) is an N by k array over v symbols in which "
             "every choice of t columns shows every one of the v<sup>t</sup> value "
             "combinations in some row. This table records, for each strength t and "
             "alphabet size v, the smallest known N for each number of columns k, and "
             "says where every entry comes from. The baseline is the November 2024 "
             "status of Charles J. Colbourn's covering array tables as preserved by "
             "Ulrike Groemping in the CAs R package (tier CITED). Entries with an "
             "explicit array in hand were checked exhaustively by a verifier and carry "
             "the array's SHA-256 and a stamp (tier VERIFIED). Arrays too large to check "
             "in full on the public runner were screened on random column windows "
             "(tier SCREENED); they are listed but do not count as best known.</p>")
    H.append("<p>Rows are stair-steps: an entry (t, v, k, N) means N runs suffice for up "
             "to k columns, so the best known N at k is the smallest N among entries with "
             "at least k columns. The construction column names the construction or "
             "search that produced each entry, where it is known. For every array on file, "
             "constant rows is the largest number of its rows that can be made constant by "
             "permuting symbols within columns, a property that matters when the array is an "
             "ingredient of another construction. Anyone can add an array by pull request; see "
             "<a href=\"%s/blob/main/submissions/README.md\">how to submit</a>. The data "
             "is <a href=\"%s/tree/main/table\">table/ in the repository</a>; the raw file "
             "<a href=\"%s\">table/ca_table.csv</a> is the machine-readable form "
             "(see the README for the stair-step rule and an R snippet).</p>"
             % (REPO_URL, REPO_URL, RAW_CSV))
    H.append("<ul class=\"stats\">")
    for label, n in (("table rows", len(rows)), ("verified rows", tiers["VERIFIED"]),
                     ("screened rows", tiers["SCREENED"]), ("arrays on file", len(manifest)),
                     ("verified arrays", len(manifest) - mstat["screened"]),
                     ("screened arrays", mstat["screened"]),
                     ("community submissions", len(subs))):
        H.append("<li>%s <b>%s</b></li>" % (label, "{:,}".format(n)))
    H.append("</ul>")
    H.append("<p class=\"mute\">Generated %s from table/ca_table.csv and "
             "table/MANIFEST.csv.</p>" % html.escape(date))

    H.append("<h2>Community submissions</h2>")
    if not subs:
        H.append("<p>None yet.</p>")
    else:
        H.append("<p class=\"mute\">One entry per submission, newest first. Open one to "
                 "see its arrays.</p>")
        H.extend(submissions_html(subs))

    H.append("<h2>Best known N by strength and alphabet</h2>")
    H.append("<p class=\"mute\">Open a (t, v) pair to see its stair-step. Each rung gives "
             "the column range it serves, the best known N, and its evidence.</p>")
    for (t, v) in sorted(by_tv):
        rs = by_tv[(t, v)]
        steps = stair(rs)
        nver = sum(1 for _, _, _, e in steps if any(r["tier"] == "VERIFIED" for r in e))
        scr = [r for r in rs if r["tier"] == "SCREENED" and r["array_sha256"] not in verified_sha]
        H.append("<details><summary>t = %d, v = %d: %d rungs, %d verified%s</summary>"
                 % (t, v, len(steps), nver,
                    ", %d screened" % len(scr) if scr else ""))
        H.append("<table><thead><tr><th class=n>k</th><th class=n>N</th>"
                 "<th>evidence</th></tr></thead><tbody>")
        for n, k0, k1, e in steps:
            krange = str(k1) if k0 == k1 else "%d to %d" % (k0, k1)
            H.append("<tr><td class=n>%s</td><td class=n>%d</td><td class=ev>%s</td></tr>"
                     % (krange, n, evidence_html(e)))
        for r in scr:
            H.append("<tr><td class=n>%d</td><td class=n>%d</td><td class=ev>"
                     "<span class=\"tag scr\">screened</span>%s%s<span class=stamp>%s, "
                     "not counted as best known%s</span></td></tr>"
                     % (r["k"], r["N"], html.escape(credit_of(r) + "; ") if credit_of(r) else "",
                        ("<i>%s</i>; " % html.escape(construction_of(r)) if construction_of(r) else "")
                        + html.escape(r["source_detail"]), html.escape(r["verify_stamp"]),
                        (", " + constant_rows_of(r)) if constant_rows_of(r) else ""))
        H.append("</tbody></table></details>")
    H.append("</main></body></html>")
    return "\n".join(H) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--table-dir", default=os.path.join(REPO, "table"))
    ap.add_argument("--out", default=os.path.join(REPO, "docs", "index.html"))
    ap.add_argument("--date", default=None)
    a = ap.parse_args()
    date = a.date or datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    rows, manifest = load(a.table_dir)
    page = render(rows, manifest, date)
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    with open(a.out, "w", encoding="utf-8") as f:
        f.write(page)
    print("wrote %s (%d bytes)" % (a.out, len(page.encode("utf-8"))))


if __name__ == "__main__":
    main()
