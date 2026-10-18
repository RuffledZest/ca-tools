## arith_formula_powercz.R - the "Power CZ" family (215 table
## rows, 212 unresolved), Colbourn and Zhou (2012), "Improving two
## recursive constructions for covering arrays", J. Statist. Theory
## Practice 6, 30-47. Paper read by eye on 2026-09-12; findings/POWERCZ_NOTES.md
## has the theorem statements verbatim. The tag "Power CZ e-q.u1-w2.u2-..."
## is the "Type" column of the paper's Tables 3 and 4: a hash family of
## M = sum u_i rows (u_i rows of width w_i) on q^e (+ extra) columns.
##
## Theorems read (by number, as printed): Theorem 2.1 (Colbourn and
## Torres-Jimenez 2010, the Power CT law); Theorem 2.2 (column
## replacement with a Phi-separating heterogeneous hash family and
## quilting arrays: CA(sum_i R_i; t, k, v)); Lemma 2.3 (a DHHF in which
## two columns agree in at most s - 1 rows is Phi-separating when every
## species S lies in Psi_i for more than (s - 1) tau(S) rows i, tau = the
## number of unequal pairs in S); Lemma 2.4 (Colbourn 2009b, the Turan
## DHF with (s-1) T(t,v) + 1 rows from OA(q^s, q+1, q, s)); Lemmas 3.1-3.8
## and Table 1 (S-QAN(t,k,2), t = 4..6, k <= 23) and Table 2
## (T-QAN(t,k,3), t = 3..6, k <= 25), the quilting array sizes; Section 5
## (Theorems 5.1, 5.2, Lemmas 5.3, 5.4: nested Roux-type bounds for
## CAN(t, 2q, q), not used by any Power CZ row).
##
## The size law of Theorem 2.2 is N = sum_i R_i with R_i the size of the
## quilting array on row i; the paper gives no assignment rule and no
## closed form, so the law calibrated here is
##   N = min over assignments Phi meeting Lemma 2.3 (s = e) of
##       sum_i QAN(Psi_i, t, w_i, v), sizes from Tables 1-2 (cz_tables.R),
## solved exactly by a dynamic programme over the rows (state = rows
## that have missed each species class, capped at its allowance
## M - r). Readings of the species sets and of the constant species:
##   L1  every Table 1 set (weight intervals and their mirrors); the two
##       constant species covered inside a row at the table's price or
##       appended at 1 row each
##   L2  nonconstant sets only, v constant rows appended (Theorem 2.1's
##       accounting)
##   L3  nested symmetric sets S_{j,t-j} only (species with tau >= j(t-j),
##       the binary analogue of Table 2's T_x), constants as L1
##   L4  L3 plus the two one-constant arrays S_{0,t-1} and S_{1,t}
##   L4f L4 with two ingredient values fitted from the record: the
##       S_{1,5}-type array at t = 6 costs 299 at width 19 (Table 1: 298)
##       and 275 at width 18 (Table 1: 279); 23 and 7 rows of different
##       shapes agree on them
## Ternary rows use Table 2's nested T_x sets under the same law (L1 and
## L4 coincide). Domain of the paper's tables: v = 2 with widths <= 23
## (68 rows) and v = 3 with widths <= 25 (28 rows).
## Result (results/arith_formula_powercz_result.txt): L4 exact on 41 of the 68
## binary rows with the paper's sizes as printed; L4f exact on 65 (all
## but the three q = 9 rows at t = 4, whose record is 8 below any
## assignment Lemma 2.3 allows, as is the paper's own Table 3 entry;
## the paper's own Table 3-4 entries at 19^19, 19^18 17^1 and 11^6 10^4
## are also below the Lemma 2.3 minimum, so the paper's assignment rule
## is looser than its Lemma 2.3 and is not stated).
## Not reproducible: t = 3, v = 3 (27 rows, M = 6 where Lemma 2.3 needs
## 7, and the record decomposes into Table 2 sizes inconsistently); t =
## 6, v = 3 (3 rows: record 675 below the law at width 19, widths 27
## outside Table 2); v = 6 (117 rows: the paper has no quilting arrays
## for v = 6). Tiers: exact under L4f -> RECURSIVE_TENTATIVE (the csv does not separate the 41 rows exact under L4 as printed from the 24 that need a fitted value; the result file lists both counts) (the quilting
## array sizes are the paper's, not the living table's, and two are
## fitted); record above the law -> RECURSIVE_STALE; else OPEN. No row
## is RECURSIVE and nothing is wired into arith_laws.R.
## Run from r/livingtable/ (paths adjusted for the repository layout; cz_tables.R
## is sourced from the same directory):
##   Rscript arith_formula_powercz.R | tee results/arith_formula_powercz_result.txt
suppressMessages(library(CAs)); data(colbournBigFrame); cb <- colbournBigFrame
source("cz_tables.R")
ec <- function(t, w, v) { r <- tryCatch(eCAN(t, w, v), error = function(e) NULL); if (is.null(r)) NA else as.numeric(r$CAN) }
Turan <- CAs:::Turan
p <- cb[grepl("^Power CZ", cb$Source), ]; p <- p[order(p$t, p$v, p$k), ]
parse_cz <- function(s) { e <- as.numeric(sub("Power CZ([0-9]+)-.*", "\\1", s)); body <- sub("Power CZ[0-9]+-", "", s)
    segs <- strsplit(body, "-")[[1]]; w <- as.numeric(sub("\\..*", "", segs)); u <- as.numeric(sub(".*\\.", "", segs))
    list(e = e, q = w[1], w = w[u > 0], u = u[u > 0], M = sum(u)) }
pars <- lapply(p$Source, parse_cz)
p$e <- sapply(pars, `[[`, "e"); p$q <- sapply(pars, `[[`, "q"); p$M <- sapply(pars, `[[`, "M")
p$Mct <- (p$e - 1) * mapply(Turan, p$t, p$v) + 1
p$wmax <- sapply(pars, function(z) max(z$w))
cat("Power CZ rows:", nrow(p), "\n"); print(table(t = p$t, v = p$v))
cat("M = sum u_i equals the Turan row count (e-1) T(t,v) + 1 on", sum(p$M == p$Mct), "rows; one less on", sum(p$M == p$Mct - 1),
    "(all t = 3, v = 3:", sum(p$M == p$Mct - 1 & p$t == 3), ")\n")

## ---- min-cost assignment under Lemma 2.3: DP over the rows ----
## classes: species classes with requirement r (rows that must carry the
## class); sets: logical vectors over classes; cost[set, width group];
## grp: width group of each row; const: classes of constant species,
## appended at 'capp' each when no row carries them. The state is the
## number of rows so far NOT carrying each class, capped at its
## allowance M - r (a state past the allowance is dead), and a covered
## flag for each constant class. Returns the minimum with the sets used.
mincost <- function(r, sets, cost, grp, const, capp) {
    M <- length(grp)
    if (any(r > M)) return(NA)                    # a class needing more rows than the family has: no assignment
    allow <- M - r; allow[const] <- 1             # constants: flag 0/1 (covered), dims 2
    keep <- which(r > 0)
    if (!length(keep)) return(NA)
    dims <- allow[keep] + 1; n <- prod(dims); strides <- cumprod(c(1, dims))[seq_along(dims)]
    coord <- lapply(seq_along(keep), function(j) ((0:(n - 1)) %/% strides[j]) %% dims[j])
    isconst <- keep %in% const
    ## per width group, a set is dominated when a superset costs no more
    usable <- sapply(seq_len(ncol(cost)), function(g) sapply(seq_along(sets), function(s) !any(sapply(seq_along(sets), function(s2)
        s2 != s && all(sets[[s2]] | !sets[[s]]) && !is.na(cost[s2, g]) && cost[s2, g] <= cost[s, g] && (cost[s2, g] < cost[s, g] || s2 < s)))))
    usable <- matrix(usable, nrow = length(sets))
    ## transition index for each set: state -> state after a row with that set (NA = dead)
    trans <- lapply(sets, function(sv) { idx <- rep(0, n); dead <- rep(FALSE, n)
        for (j in seq_along(keep)) { cj <- coord[[j]]
            if (isconst[j]) { if (sv[keep[j]]) cj <- rep(1, n) }
            else if (!sv[keep[j]]) { cj <- cj + 1; dead <- dead | cj > allow[keep[j]] }
            idx <- idx + cj * strides[j] }
        idx <- idx + 1; idx[dead] <- NA; idx })
    A <- rep(Inf, n); A[1] <- 0
    back <- vector("list", M)                     # per row: the set and the predecessor state of each state's best value
    for (i in seq_len(M)) {
        B <- rep(Inf, n); bs <- rep(NA, n); bp <- rep(NA, n)
        for (s in seq_along(sets)) {
            c <- cost[s, grp[i]]; if (is.na(c) || !usable[s, grp[i]]) next
            tg <- trans[[s]]; ok <- which(!is.na(tg) & is.finite(A))
            if (!length(ok)) next
            val <- A[ok] + c; o <- order(val, decreasing = TRUE)      # scatter-min: smallest written last
            tmp <- rep(Inf, n); tmp[tg[ok][o]] <- val[o]
            src <- rep(NA, n); src[tg[ok][o]] <- ok[o]
            better <- tmp < B; B[better] <- tmp[better]; bs[better] <- s; bp[better] <- src[better] }
        back[[i]] <- list(s = bs, p = bp); A <- B }
    add <- rep(0, n); for (j in seq_along(keep)) if (isconst[j]) add <- add + capp * (coord[[j]] == 0)
    v <- A + add
    for (cc in const) if (!(cc %in% keep)) v <- v + capp       # r = 0 constant class: always appended
    m <- min(v); if (!is.finite(m)) return(NA)
    st <- which.min(v); used <- integer(M)
    for (i in M:1) { used[i] <- back[[i]]$s[st]; st <- back[[i]]$p[st] }
    attr(m, "sets") <- used; attr(m, "const") <- add[which.min(v)]; m
}
## decomposition as text: "width:set x count ... +c" (c = appended constant rows)
decomp_str <- function(used, setnames, widths, cst) { tb <- table(paste0(widths, ":", setnames[used]))
    paste(c(paste0(names(tb), "x", tb), if (cst > 0) paste0("+", cst)), collapse = " ") }
## binary: classes = weights 0..t, tau = w (t - w); sets = Table 1 intervals with mirrors
qan2f <- function(t, k, a, b) {   ## L4f: the two fitted values (t = 6, the S_{1,5}-type arrays at widths 19 and 18)
    x <- qan2(t, k, a, b)
    s15 <- t == 6 && a <= 1 && b >= 5 && !(a == 0 && b == 6)     # S_{1,5}, S_{0,5}, S_{1,6}
    if (s15 && k == 19) return(299)
    if (s15 && k == 18) return(275)
    x }
law_binary <- function(t, e, w, u, reading) {
    M <- sum(u); r <- (e - 1) * (0:t) * (t:0) + 1; names(r) <- 0:t
    S <- T1_sets[[as.character(t)]]; S <- unique(c(S, lapply(S, function(s) c(t - s[2], t - s[1]))))
    if (reading == "L2") S <- Filter(function(s) s[1] >= 1 && s[2] <= t - 1, S)
    if (reading == "L3") S <- Filter(function(s) s[1] + s[2] == t, S)
    if (reading %in% c("L4", "L4f")) S <- Filter(function(s) s[1] + s[2] == t || (s[1] == 0 && s[2] == t - 1) || (s[1] == 1 && s[2] == t), S)
    q <- if (reading == "L4f") qan2f else qan2
    sets <- lapply(S, function(s) 0:t >= s[1] & 0:t <= s[2])
    cost <- matrix(sapply(w, function(k) sapply(S, function(s) q(t, k, s[1], s[2]))), nrow = length(S))
    if (any(is.na(cost))) return(NA)
    const <- c(1, t + 1); if (reading == "L2") r[const] <- 0
    m <- mincost(r, sets, cost, rep(seq_along(w), u), const, 1)
    if (!is.na(m)) attr(m, "decomp") <- decomp_str(attr(m, "sets"), sapply(S, function(s) paste0("S", s[1], s[2])), rep(w, u), attr(m, "const") + (if (reading == "L2") 2 else 0))
    m
}
## ternary: classes = tau values; sets = T_x thresholds (tau >= x); T_0 holds the constants
law_ternary <- function(t, e, w, u, reading) {
    M <- sum(u); taus <- tau_ternary(t); r <- (e - 1) * taus + 1
    xs <- T2_x[[as.character(t)]]; if (reading == "L2") xs <- xs[xs > 0]
    sets <- lapply(xs, function(x) taus >= x)
    cost <- matrix(sapply(w, function(k) sapply(xs, function(x) qan3(t, k, x))), nrow = length(xs))
    if (any(is.na(cost))) return(NA)
    const <- 1; if (reading == "L2") r[1] <- 0
    m <- mincost(r, sets, cost, rep(seq_along(w), u), const, 3)
    if (!is.na(m)) attr(m, "decomp") <- decomp_str(attr(m, "sets"), paste0("T", xs), rep(w, u), attr(m, "const") + (if (reading == "L2") 3 else 0))
    m
}
law_cz <- function(i, reading) { z <- pars[[i]]; t <- p$t[i]; v <- p$v[i]
    if (v == 2 && t %in% 4:6) law_binary(t, z$e, z$w, z$u, reading)
    else if (v == 3 && t %in% 3:6) law_ternary(t, z$e, z$w, z$u, reading) else NA }
t0 <- proc.time()[3]
readings <- c("L1", "L2", "L3", "L4", "L4f")
res <- lapply(readings, function(rd) lapply(seq_len(nrow(p)), law_cz, reading = rd)); names(res) <- readings
for (rd in readings) p[[paste0("N_", rd)]] <- sapply(res[[rd]], as.numeric)
p$decomp_L4 <- sapply(res$L4, function(z) if (is.na(z)) "" else attr(z, "decomp"))
p$decomp_L4f <- sapply(res$L4f, function(z) if (is.na(z)) "" else attr(z, "decomp"))
cat(sprintf("DP time %.1f s\n", proc.time()[3] - t0))
p$blk <- paste0("t", p$t, " v", p$v, " e", p$e)

cat("\n== Lemma 2.3 min-cost readings: exact / record above / record below, by (t, v, e) block ==\n")
cnt <- function(N, x) sprintf("%d/%d/%d", sum(N == x, na.rm = TRUE), sum(N > x, na.rm = TRUE), sum(N < x, na.rm = TRUE))
sm <- do.call(rbind, lapply(split(seq_len(nrow(p)), p$blk), function(ii) { N <- p$N[ii]
    data.frame(block = p$blk[ii[1]], rows = length(ii), evaluable = sum(!is.na(p$N_L1[ii])),
        L1 = cnt(N, p$N_L1[ii]), L2 = cnt(N, p$N_L2[ii]), L3 = cnt(N, p$N_L3[ii]), L4 = cnt(N, p$N_L4[ii]), L4f = cnt(N, p$N_L4f[ii])) }))
print(sm[order(sm$block), ], row.names = FALSE)
for (rd in readings) cat(sprintf("%-4s exact %2d  above %2d  below %2d  (of %d evaluable, %d rows)\n", rd, sum(p$N == p[[paste0("N_", rd)]], na.rm = TRUE),
    sum(p$N > p[[paste0("N_", rd)]], na.rm = TRUE), sum(p$N < p[[paste0("N_", rd)]], na.rm = TRUE), sum(!is.na(p[[paste0("N_", rd)]])), nrow(p)))

cat("\nbinary rows: the record against L4 (paper sizes as printed) and L4f (two fitted sizes); d = N - law\n")
b <- p[p$v == 2, ]; b$dL1 <- b$N - b$N_L1; b$dL4 <- b$N - b$N_L4; b$dL4f <- b$N - b$N_L4f
print(b[, c("t","k","N","Source","M","N_L1","dL1","N_L4","dL4","N_L4f","dL4f")], row.names = FALSE)
cat("\nL4f decompositions (width:set x rows; +c = appended constant rows) of the binary rows:\n")
for (i in seq_len(nrow(b))) cat(sprintf("  %-32s N=%5d L4f=%5d  %s\n", b$Source[i], b$N[i], b$N_L4f[i], b$decomp_L4f[i]))
cat("\nthe q = 19 pattern behind L4f: N - N_L4 against the number of S_{1,5}-type rows at width 19 and at width 18 in the L4 optimum\n")
q19 <- b[(b$t == 6 & b$q == 19) | b$Source == "Power CZ3-23.18-18.1", ]
n19 <- sapply(strsplit(q19$decomp_L4, " "), function(z) sum(as.numeric(sub(".*x", "", z[grepl("^19:S(05|16|15)", z)]))))
n18 <- sapply(strsplit(q19$decomp_L4, " "), function(z) sum(as.numeric(sub(".*x", "", z[grepl("^18:S(05|16|15)", z)]))))
cat("  rows:", nrow(q19), "  N - N_L4 == n19 - 4 n18 on", sum(q19$N - q19$N_L4 == n19 - 4 * n18), "of them\n")

cat("\nternary rows (t = 3: M = 6 < 7 rows that Lemma 2.3 needs for the all-distinct species, so no assignment exists; t = 6: width 27 is outside Table 2):\n")
g <- p[p$v == 3, ]; print(g[, c("t","k","N","Source","M","Mct","wmax","N_L1","N_L2")], row.names = FALSE)
## t = 3, v = 3: decompositions of the record into Table 2 arrays (T_0, T_2, T_3 at each width) with 0..3 constant rows
cat("\nt = 3, v = 3: decompositions of the record into Table 2 arrays (counts of T0,T2,T3 per width; +c constant rows); any row requirement ignored\n")
comp3 <- function(u) { out <- NULL; for (a in 0:u) for (b2 in 0:(u - a)) out <- rbind(out, c(a, b2, u - a - b2)); out }
g3 <- which(p$t == 3); ndec <- integer(0)
for (i in g3) { z <- pars[[i]]; N <- p$N[i]
    parts <- lapply(seq_along(z$w), function(gi) { cm <- comp3(z$u[gi]); list(cm = cm, cost = as.vector(cm %*% c(qan3(3, z$w[gi], 0), qan3(3, z$w[gi], 2), qan3(3, z$w[gi], 3)))) })
    tot <- parts[[1]]; if (length(parts) > 1) for (gi in 2:length(parts)) { n1 <- length(tot$cost); n2 <- length(parts[[gi]]$cost); i1 <- rep(seq_len(n1), each = n2); i2 <- rep(seq_len(n2), n1)
        tot <- list(cm = cbind(tot$cm[i1, , drop = FALSE], parts[[gi]]$cm[i2, , drop = FALSE]), cost = tot$cost[i1] + parts[[gi]]$cost[i2]) }
    found <- c(); for (cst in 0:3) for (h in which(tot$cost + cst == N)) found <- c(found, paste0(paste(apply(matrix(tot$cm[h, ], nrow = 3), 2, paste, collapse = ","), collapse = " | "), " +", cst))
    ndec <- c(ndec, length(found))
    cat(sprintf("  %-32s N=%3d widths %-18s %d decomposition(s)%s\n", p$Source[i], N, paste(z$w, z$u, sep = "x", collapse = " "), length(found),
        if (length(found) && length(found) <= 3) paste0(": ", paste(found, collapse = "; ")) else "")) }
cat("  rows with no decomposition:", sum(ndec == 0), "; the single-decomposition rows disagree on the constant rows (14^6 = 6 T_3 + 3; 16^6 = 2 T_2 + 4 T_3 + 0), so Table 2 is not the ingredient library of these rows\n")
cat("  the Theorem 2.1 accounting with the living table's eCAN (every row eCAN(3, w, 3) - 3, plus 3):",
    sum(sapply(g3, function(i) { z <- pars[[i]]; sum(z$u * (sapply(z$w, ec, t = 3, v = 3) - 3)) + 3 }) == p$N[g3]), "exact; record below it on all", length(g3), "rows by 6..19\n")

## ---- the paper's own Table 3 / Table 4 entries against the same readings ----
cat("\nthe paper's own Tables 3-4 (New column) against L1 / L4 with its own Table 1-2 sizes:\n")
own <- data.frame(t = c(4,4,4,4, 6,6, 3,3,3), v = c(2,2,2,2, 2,2, 3,3,3), e = c(3,3,4,3, 3,3, 3,3,4),
    type = c("9^9", "11^8 10^1", "12^12 10^1", "13^3 12^6", "19^19", "19^18 17^1", "20^6", "19^6", "11^6 10^4"),
    New = c(184, 196, 284, 216, 4969, 4904, 333, 318, 354), stringsAsFactors = FALSE)
own$w <- list(9, c(11,10), c(12,10), c(13,12), 19, c(19,17), 20, 19, c(11,10)); own$u <- list(9, c(8,1), c(12,1), c(3,6), 19, c(18,1), 6, 6, c(6,4))
ownlaw <- function(i, rd) as.numeric(if (own$v[i] == 2) law_binary(own$t[i], own$e[i], own$w[[i]], own$u[[i]], rd) else law_ternary(own$t[i], own$e[i], own$w[[i]], own$u[[i]], rd))
own$L1 <- sapply(seq_len(nrow(own)), ownlaw, rd = "L1"); own$L4 <- sapply(seq_len(nrow(own)), ownlaw, rd = "L4")
print(own[, c("t","v","e","type","New","L1","L4")], row.names = FALSE)
cat("(9^9, the t = 6 entries and 11^6 10^4 lie BELOW the Lemma 2.3 minimum with the paper's own sizes, so the paper's own Table 3-4 assignment\n",
    " is looser than Lemma 2.3 as stated (11^6 10^4 = 3 T_2 + 3 T_3 at 11, 4 T_3 at 10, + 3 puts the tau = 2 species in 3 rows where Lemma 2.3 wants 7);\n",
    " 20^6 and 19^6 have 6 rows where Lemma 2.3 needs 7. The living table's rows, unlike the paper's, sit at or above the Lemma 2.3 minimum except at q = 9)\n")

## ---- v = 6: no quilting arrays in the paper; the residual against the Power CT law as evidence ----
cat("\n== v = 6 rows (t = 5, e = 3, M = 21): no v = 6 quilting arrays anywhere in the paper ==\n")
s6 <- p[p$v == 6, ]; i6 <- which(p$v == 6)
s6$N_ct <- sapply(i6, function(i) { z <- pars[[i]]; sum(z$u * (sapply(z$w, ec, t = 5, v = 6) - 1)) + max(0, 6 - 5 * z$M) })
s6$res <- s6$N - s6$N_ct
s6$n23 <- sapply(pars[i6], function(z) sum(z$u[z$w == 23])); s6$n22 <- sapply(pars[i6], function(z) sum(z$u[z$w == 22])); s6$n21 <- sapply(pars[i6], function(z) sum(z$u[z$w == 21]))
cat("residual N - Power CT law (eCAN - 1 per row, chi): range", paste(range(s6$res), collapse = ".."), " distinct values", length(unique(s6$res)), "on", nrow(s6), "rows\n")
cat("residual by n22 on the rows with widths 23, 22, 21 only, n23 >= 8, n21 >= 2 (a per-row saving that depends on the row's set, not one number per width):\n")
x <- s6[s6$n23 + s6$n22 + s6$n21 == 21 & s6$n21 >= 2 & s6$n23 >= 8, ]
print(aggregate(res ~ n22, data = x, FUN = function(z) paste(unique(z), collapse = "/")), row.names = FALSE)
fit <- lm(N ~ n23 + n22 + n21, data = s6)
cat("an additive per-width fit N = a + b23 n23 + b22 n22 + b21 n21 misses by up to", round(max(abs(resid(fit)))), "rows\n")

## ---- tiers ----
## N_pred: L4f on the binary rows (L4 where no fitted width is involved gives the same number), L1 on the ternary rows
p$N_pred <- ifelse(p$v == 2, p$N_L4f, p$N_L1)
p$tier <- ifelse(is.na(p$N_pred), "OPEN", ifelse(p$N == p$N_pred, "RECURSIVE_TENTATIVE", ifelse(p$N > p$N_pred, "RECURSIVE_STALE", "OPEN")))
cat("\n== TIERS over all", nrow(p), "Power CZ rows (law L4f on v = 2, L1 on v = 3; ingredients = the paper's Tables 1-2, two values fitted) ==\n")
print(table(p$blk, p$tier))
cat("exact under L4 alone (no fitted value):", sum(p$N == p$N_L4, na.rm = TRUE), "; exact only with a fitted value:", sum(p$N == p$N_L4f & (is.na(p$N_L4) | p$N != p$N_L4), na.rm = TRUE), "\n")
cv <- read.csv("data/engine_coverage.csv", stringsAsFactors = FALSE)
u <- cv[cv$engine_class == "UNRESOLVED" & grepl("^Power CZ", cv$Source), ]
m <- match(paste(u$t, u$v, u$k, u$Source), paste(p$t, p$v, p$k, p$Source))
cat("unresolved Power CZ entries:", nrow(u), " matched:", sum(!is.na(m)), "\n"); print(table(p$tier[m], useNA = "ifany"))
p$family <- "Power CZ"
write.csv(p[, c("family","t","v","k","N","Source","N_pred","tier")], "data/arith_formula_powercz.csv", row.names = FALSE)
cat("\nPOWER CZ FORMULA RUN DONE\n")
