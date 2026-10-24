# Finding: three entries recorded as "Cyclotomy (Colbourn)" whose type 3a construction does not give a covering array

First written 2026-08-29 for CAN(3, 128, 6); extended to three entries
after the catalogue audit of 2026-08-30; status notes added 2026-09-05
and 2026-10-23. The entries are CAN(3, 128, 6) = 762,
CAN(3, 2162, 20) = 43,220 and CAN(3, 2312, 21) = 48,531 in the November
2024 snapshot of Colbourn's tables.

## Status (2026-10-23)

Colbourn (2010), Covering arrays from cyclotomy, Des. Codes Cryptogr.
55, 201-219, was read on 2026-10-23. The three sizes are the paper's
own results (its Table 3). They come from its Table 2, which places
q = 127 (v = 6), q = 2161 (v = 20) and q = 2311 (v = 21) in the range
where the cyclotomic vector has property 3a of Construction 4.1. The
properties were recomputed from the paper's own definitions
(`../cyclotomy_recheck.py`, output in
`../results/cyclotomy_recheck_result.txt`). At each of the three q the
vector meets every condition of type 3a except that the constant
pattern (all three entries equal) never occurs on some sets of three
columns. So it has property 4a and not 3a, and at q = 127 the type 3a
array leaves the same 5,334 column triples uncovered as the August
check below. This explains why the fix in CAs (type 4a, commit ae81661)
works: type 4a adds a constant row, which supplies that pattern. The
question left open below is answered: the table copied the paper
correctly, and the paper lists these q under property 3a where it
does not hold. That the paper's tables contain mistakes was noted
before by Ulrike Groemping, in the CAs documentation and in her report
Implementing uniform covering arrays based on the Colbourn tables
(Report 01/2026, BHT Berlin, Section 6.1).

The table records each entry with a DISPUTED row beside the unchanged
CITED row, and the verified 768-row type 4a array at (3, 128, 6) as a
VERIFIED row (`../../../table/VERIFICATION_LOG.md`, section of
2026-10-23). None of this shows that the recorded sizes cannot be
reached by another construction.

## Status (2026-09-05): fixed in CAs

The CAs commit ae81661 of 2026-09-04 switched these three CYCLOTOMYcat
rows to type 4a (sizes vq + v: 768, 43,240 and 48,552). The type 4a
arrays were checked here (`../mac_4a_q127.R`: full verification at
q = 127; `../mac_4a_check.R`: 48 caverify windows each at q = 2161 and
q = 2311, all pass; logs in `../results/`). The sections below are the
record as written before the fix, with wording made plain.

## Catalogue audit, 2026-08-30 (213 rows)

210 of the 213 CYCLOTOMYcat rows pass (16 verified in full, 194 pass a
50-column screen). Three fail, all type 3a, all matching table entries
recorded as "Cyclotomy (Colbourn)", and all smaller than every other
route in `CAs::Ns`, so `CAs::bestCA` returned each failing array
without warning:

  t=3 k=128  v=6   N=762    q=127   (full verification fails)
  t=3 k=2162 v=20  N=43220  q=2161  (a 50-column window fails)
  t=3 k=2312 v=21  N=48531  q=2311  (a 50-column window fails)

A failing window is enough: every set of columns of a covering array
must itself cover. The common type suggested one cause, the type 3a
condition failing at these q while the catalogue rows were taken from
the tables (the CAs documentation notes that the checks take a long
time for large cases).

Follow-up the same day: screens of four 50-column windows (first,
last and two random) on all 194 large rows found no further failure.
The type 3b construction at the same q gave arrays that pass:
CA(792; 3, 128, 6) verified in full, and 43,600 x 2162 (v = 20) and
48,951 x 2312 (v = 21) passing all four windows. Each is v(v - 1) rows
above the failing type 3a size (30, 380 and 420). Files:
`../data/cyclotomy_audit2.csv`, `../data/cyclotomy_screen4.csv`, logs
in `../results/`. The paper check was then still open; it is answered
in the status section above.

## The first check, 2026-08-29: CAN(3, 128, 6)

The snapshot (colbournBigFrame in CAs 0.24) records CAN(3, 128, 6) <=
762 with Source "Cyclotomy (Colbourn)". CAs maps this to
`cyc(127, 6, type = "3a")`, 762 = 6 x 127 rows, k = q + 1 = 128.

1. The type 3a array (762 x 128) is not a covering array of strength
   3: 5,334 of the 341,376 column triples are not covered, 32,004
   tuples are missing. caverify and `CAs::coverage()` agree.
2. The primitive element is not the cause: all 36 primitive roots of
   GF(127) were tried, and none gives a covering array.
3. The CAs condition checker `checkcond3a(3, 6, 127)` returns FALSE:
   the type 3a condition does not hold at q = 127. The checker returns
   TRUE on the control rows (3, 4, 53) and (4, 2, 23), whose arrays
   verify.
4. Of 15 CYCLOTOMYcat rows small enough to check cheaply, 14 pass,
   including six other type 3a rows.
5. Type 3b at the same q gives a 792 x 128 array that verifies (its
   checker condition is FALSE, but the conditions are sufficient, not
   necessary, and the array itself was checked).

At the time this was stated as "the entry's cited support does not
hold and the best verified value is 792", not as CAN(3, 128, 6) = 792
and not as "the table is wrong by 30". The verified value is now 768
(type 4a, above), and the same caution applies.

Practical consequence at the time: `bestCA(3, 128, 6)` returned a
non-covering array, because the failing 762 route was the smallest.
This was fixed in CAs by type 4a (status section above).
