"""sms_theorem51.py - build the strength-4 covering array of Shokri, Moura and Stevens,
arXiv:2510.13122v2, Theorem 5.1, for an odd prime q (prime only: F_q arithmetic is mod q).
Used for the table entries CA(43921; 4, 61, 11) and CA(85681; 4, 85, 13) (table/VERIFICATION_LOG.md).

Theorem 5.1: alpha primitive in F_{q^4}; A_l = A([G^{l(q+1)}_{q^2+1}]_p) for l = 1, 2, 4,
where (Construction 2.4) G^m_c has columns L(alpha^(m i)), 0 <= i < c, L(x) the coordinate
vector of x in the basis 1, alpha, alpha^2, alpha^3, and [.]_p keeps the columns
i + p_i (q^2+1)/2, 0 <= i < (q^2+1)/2, for a choice p in {0,1}^((q^2+1)/2);
A(G) is the q^4 x c array of all F_q-linear combinations of the rows of G.
The vertical concatenation of A_1, A_2, A_4 with two of the three all-zero rows removed is
claimed to be a CA(3q^4 - 2; 4, (q^2+1)/2, q).

Usage: python3 tools/sms_theorem51.py q [p-bits as a 0/1 string, default all zeros] > out.txt
Writes the array as canonical text (0-based, space-separated, one row per line) to stdout;
the primitive polynomial and p are printed to stderr.
"""
import sys, itertools
import numpy as np

def poly_mulmod(a, b, f, q):
    """a, b: coefficient lists (low degree first, length 4); f: monic degree-4 (length 5)."""
    r = [0] * 7
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                r[i + j] = (r[i + j] + x * y) % q
    for d in range(6, 3, -1):           # reduce x^d using f
        c = r[d]
        if c:
            r[d] = 0
            for k in range(4):
                r[d - 4 + k] = (r[d - 4 + k] - c * f[k]) % q
    return r[:4]

def find_primitive(q):
    order = q ** 4 - 1
    primes = [p for p in range(2, order + 1) if order % p == 0 and all(p % d for d in range(2, int(p ** 0.5) + 1))]
    for coeffs in itertools.product(range(q), repeat=4):   # f = x^4 + c3 x^3 + ... + c0
        if coeffs[0] == 0:
            continue
        f = list(coeffs) + [1]
        x = [0, 1, 0, 0]
        def power(e):
            res, base = [1, 0, 0, 0], x[:]
            while e:
                if e & 1: res = poly_mulmod(res, base, f, q)
                base = poly_mulmod(base, base, f, q); e >>= 1
            return res
        if power(order) != [1, 0, 0, 0]:
            continue
        if all(power(order // p) != [1, 0, 0, 0] for p in primes):
            return f
    raise ValueError("no primitive polynomial found")

def main():
    q = int(sys.argv[1]); assert q % 2 == 1 and all(q % d for d in range(2, q)), "q must be an odd prime here"
    half = (q * q + 1) // 2
    p = [int(c) for c in sys.argv[2]] if len(sys.argv) > 2 else [0] * half
    assert len(p) == half and set(p) <= {0, 1}
    f = find_primitive(q)
    # powers of alpha as coordinate vectors L(alpha^j), j = 0 .. q^4 - 2
    n = q ** 4 - 1
    L = np.zeros((n, 4), dtype=np.int64); cur = [1, 0, 0, 0]
    for j in range(n):
        L[j] = cur; cur = poly_mulmod(cur, [0, 1, 0, 0], f, q)
    cols = [i + p[i] * half for i in range(half)]
    U = np.array(list(itertools.product(range(q), repeat=4)), dtype=np.int64)  # all q^4 row vectors u
    blocks = []
    for l in (1, 2, 4):
        G = np.stack([L[(l * (q + 1) * i) % n] for i in cols], axis=1)          # 4 x half
        A = (U @ G) % q                                                          # q^4 x half
        blocks.append(A)
    M = np.vstack(blocks)
    zero = np.where(~M.any(axis=1))[0]
    assert len(zero) == 3, zero
    M = np.delete(M, zero[1:], axis=0)                                           # keep one all-zero row
    sys.stderr.write("q=%d primitive polynomial x^4 + %s (low degree first: %s); p=%s; N=%d k=%d\n"
                     % (q, f[3::-1], f, "".join(map(str, p)), M.shape[0], M.shape[1]))
    out = sys.stdout
    for row in M:
        out.write(" ".join(map(str, row.tolist())) + "\n")

if __name__ == "__main__":
    main()
