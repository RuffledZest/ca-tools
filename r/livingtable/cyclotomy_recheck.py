#!/usr/bin/env python3
"""cyclotomy_recheck.py - recomputes, from the definitions in Colbourn (2010),
Covering arrays from cyclotomy, Des. Codes Cryptogr. 55, 201-219, whether the
cyclotomic vector has property 3a or 4a of Construction 4.1 at strength 3 for
the three q behind the table's DISPUTED cyclotomy entries, and checks the
resulting arrays at q = 127 in full.

Definitions used (Section 2 and Construction 4.1 of the paper): q prime,
v | q - 1, w a primitive element; x_0 = 0 and x_i = j mod v when i = w^j;
A = (a_ij) with a_ij = x_{j-i}. Property 3 (t = 3): for every set {i1, i2, i3}
of positions and every (s1, s2, s3) there are a and r with
x_{i_j + a} = s_j + r (mod v). Property 3a: property 3, and for every pair
{i1, i2} and every (s1, s2) an a with x_{i_j + a} = s_j exactly. Property 4a:
the same with the constant patterns (s, s, s) excused in property 3. Type 3a
builds CA(vq; 3, q + 1, v) by adding a zero column to A and developing modulo
v; type 4a also adds a zero row first, giving CA(vq + v; 3, q + 1, v).

By translation, every set of positions can be moved to {0, b, c} with
0 < b < c < q; the script tests all of those. Run from r/livingtable/:
    python3 cyclotomy_recheck.py | tee results/cyclotomy_recheck_result.txt
Needs Python 3 and numpy. Takes a few minutes.
"""
from itertools import combinations
import numpy as np


def primitive_roots(q):
    f, n, p = [], q - 1, 2
    while p * p <= n:
        if n % p == 0:
            f.append(p)
            while n % p == 0:
                n //= p
        p += 1
    if n > 1:
        f.append(n)
    return [g for g in range(2, q) if all(pow(g, (q - 1) // d, q) != 1 for d in f)]


def cyclotomic_vector(q, v, w):
    x = np.zeros(q, dtype=np.int64)
    e = 1
    for j in range(q - 1):
        x[e] = j % v
        e = e * w % q
    return x


def property_counts(q, v, x):
    """sets {0, b, c} failing property 3; of these, how many miss only the
    constant pattern; pairs {0, b} failing the exact pair condition"""
    idx = np.arange(q)
    fail3 = only_const = 0
    for b in range(1, q - 1):
        d1 = (x[(idx + b) % q] - x) % v
        cs = np.arange(b + 1, q)
        d2 = (x[(idx[None, :] + cs[:, None]) % q] - x[None, :]) % v
        code = d1[None, :] * v + d2
        seen = np.zeros((len(cs), v * v), dtype=bool)
        np.put_along_axis(seen, code, True, axis=1)
        miss = ~seen
        bad = miss.any(axis=1)
        fail3 += int(bad.sum())
        only_const += int((bad & miss[:, 0] & (miss.sum(axis=1) == 1)).sum())
    pairs = sum(1 for b in range(1, q)
                if len(np.unique(x * v + x[(idx + b) % q])) < v * v)
    return fail3, only_const, pairs


def build(q, v, x, zero_row):
    A = np.array([[x[(j - i) % q] for j in range(q)] for i in range(q)], dtype=np.int64)
    if zero_row:
        A = np.vstack([A, np.zeros((1, q), dtype=np.int64)])
    A = np.hstack([A, np.zeros((A.shape[0], 1), dtype=np.int64)])
    return np.vstack([(A + d) % v for d in range(v)])


def uncovered(M, v):
    """column triples not covering all v^3 tuples, and the number of missing tuples"""
    k = M.shape[1]
    triples = tuples = 0
    for i, j in combinations(range(k), 2):
        rest = np.arange(j + 1, k)
        if len(rest) == 0:
            continue
        code = (M[:, i] * v + M[:, j])[:, None] * v + M[:, rest]
        s = np.sort(code, axis=0)
        distinct = 1 + (np.diff(s, axis=0) != 0).sum(axis=0)
        triples += int((distinct < v ** 3).sum())
        tuples += int((v ** 3 - distinct).sum())
    return triples, tuples


for q, v in ((127, 6), (2161, 20), (2311, 21)):
    roots = primitive_roots(q)
    for w in ([roots[0], roots[-1]] if q == 127 else [roots[0]]):
        x = cyclotomic_vector(q, v, w)
        f3, oc, pf = property_counts(q, v, x)
        print("q = %d, v = %d, primitive element %d: sets {0, b, c} failing property 3: %d, "
              "of these missing only the constant pattern: %d; pairs {0, b} failing the exact "
              "pair condition: %d; so %s" % (q, v, w, f3, oc, pf,
              "property 4a and not 3a" if f3 and f3 == oc and pf == 0 else
              "property 3a" if f3 == 0 and pf == 0 else "neither 3a nor 4a"), flush=True)
        if q == 127:
            for zero_row, name in ((False, "type 3a"), (True, "type 4a")):
                M = build(q, v, x, zero_row)
                tr, tu = uncovered(M, v)
                print("    %s array %d x %d: column triples not covered %d of %d, missing tuples %d"
                      % (name, M.shape[0], M.shape[1], tr, len(list(combinations(range(M.shape[1]), 3))), tu),
                      flush=True)
