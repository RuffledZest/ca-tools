## arith_formula_dcan.R - the two families whose theorems carry
## difference covering array numbers DCAN(2, k, v): "Cohen-Colbourn-Ling"
## (318 plain rows, t = 3, the k-ary Roux of CMTW Theorem 3.3 as stated
## in Colbourn, Martirosyan, Van Trung, Walker 2006, attributed there
## to Cohen, Colbourn and Ling) and the 583 strength-4 plain rows of
## "Colbourn-Martirosyan-TVT-Walker" (CMTW Section 4, forms with DCAN
## and covering ordered design numbers CODN). The DCAN source is Yin,
## "Constructions of difference covering arrays", J. Combin. Theory A
## 104 (2003) 327-339, read by eye on 2026-09-12 (findings/DCAN_NOTES.md
## holds the statements). The CMTW forms were re-read the same day
## through an automated summary of the authors' open copy (formula by
## formula, not by eye); findings/DCAN_NOTES.md records that reading.
## Conventions. Yin: a DCA(k, n; q) over an abelian group G of order q
## is a k x n array such that, for any two distinct rows, EVERY element
## of G (zero included) occurs in the difference list; n >= q, with
## equality iff a (q, k, 1) difference matrix exists. CMTW: a
## DCA(N; 2, k, v) over Z_v is an N x k array such that, for any two
## distinct columns, every NONZERO element occurs among the row
## differences; DCAN(2, k, v) is the least N. Transposing and deleting
## the column that a DCA(k, n; q) can be normalised to hold as all zeros
## (Yin, p. 328) gives DCA(n - 1; 2, k, q); adding a zero column to a
## CMTW array gives a Yin array; so DCAN_cmtw(2, k, v) = n_min(k, v) - 1
## exactly when the group is Z_v. Yin's arrays are over Z_v for
## v = 2, 6, 10, 14, 18, 22 (Example 1.1, Lemma 3.4, Theorems 3.1, 3.2)
## and, from difference matrices (Lemma 3.1), over the direct sum of
## the elementary abelian groups of the prime power factors of v,
## which is Z_v only for squarefree v; column over_Zv of data/dcan_table.csv
## records this. The Roux-type proofs add DCA entries to covering array
## symbols and go through over any abelian group of order v, so the
## non-cyclic values are used here as ingredients with that note; of
## the rows tiered RECURSIVE below, those at v = 16 and 25 rest on it
## (EA(16), EA(25)), the five at prime v do not. Yin's coverage ends at
## k <= 25 in every case and almost every row needs k' in the hundreds
## or thousands, see the run.
## Coverage of Yin for 2 <= v <= 25: DCAN_cmtw(2, k, v) = v - 1 for
## k <= min prime power factor of v (Lemma 3.1, exact); for v = 2 mod 4
## and k = 3, 4: v (Theorem 3.3, exact by n >= q + 1); v = 10, k = 5:
## 10 (Lemma 3.4, exact). Nothing for larger k.
## Result in one line: CCL 0 of 318 exact (the record sits a median 24%
## below the k-ary Roux evaluated with Yin's values; its DCAs have k'
## beyond Yin); CMTW strength 4: 7 RECURSIVE (the k = v^2 rows, Theorem
## 4.13 with DCAN(2, v, v) = v - 1 from Yin and CODN(2, v, v^2) = v^4 - v^2
## by CMTW's Bush argument applied at v^2, this pass's step, exact by the count), 11 RECURSIVE_TENTATIVE (Lemma 4.8 with one
## CODN(2, k/2, v) value read off the record at v = 3 and at v = 7), 565
## OPEN.
## Tiers: RECURSIVE exact with table ingredients and Yin's DCAN;
## RECURSIVE_TENTATIVE exact with one fitted integer that is the same across
## at least three rows of the family at the same v and lies inside the
## bounds the papers give for that quantity (a reading, not a law);
## RECURSIVE_STALE record above the law with Yin's DCAN; OPEN
## otherwise (record below the Yin law, or the form has ingredients
## the table does not hold). The fitted integers of single rows are
## written to the csv (fit_name, fit_value) and not tiered.
## Run from r/livingtable/ (paths adjusted for the repository layout):
##   Rscript arith_formula_dcan.R | tee results/arith_formula_dcan_result.txt
suppressMessages(library(CAs)); data(colbournBigFrame); cb <- colbournBigFrame
ec <- function(t, w, v) { r <- tryCatch(eCAN(t, w, v), error = function(e) NULL); if (is.null(r)) NA else as.numeric(r$CAN) }
is_pp <- function(v) { p <- 2; while (v %% p != 0) p <- p + 1; while (v %% p == 0) v <- v / p; v == 1 }
ppfac <- function(v) { out <- c(); p <- 2; while (v > 1) { if (v %% p == 0) { q <- 1; while (v %% p == 0) { v <- v / p; q <- q * p }; out <- c(out, q) }; p <- p + 1 }; out }
## eCAN(t, k, v) for every k at once: smallest recorded N at any k' >= k (checked against eCAN below)
Nk <- function(t, v) { s <- cb[cb$t == t & cb$v == v, ]; s <- s[order(s$k), ]; if (!nrow(s)) return(NULL)
    out <- rep(NA, max(s$k)); Nmin <- rev(cummin(rev(s$N)))
    for (i in seq_len(nrow(s))) { lo <- if (i == 1) 1 else s$k[i-1] + 1; out[lo:s$k[i]] <- Nmin[i] }; out }
NK <- list(); for (t in 2:4) for (v in 2:25) NK[[paste(t, v)]] <- Nk(t, v)
nk <- function(t, k, v) { x <- NK[[paste(t, v)]]; if (is.null(x) || k > length(x)) NA else x[k] }
chk <- c(nk(2, 66, 6) == ec(2, 66, 6), nk(3, 1002, 7) == ec(3, 1002, 7), nk(4, 2388, 3) == ec(4, 2388, 3), nk(2, 3072, 9) == ec(2, 3072, 9))
cat("lookup agrees with eCAN on spot checks:", all(chk), "\n")
cv <- read.csv("data/engine_coverage.csv", stringsAsFactors = FALSE)
u <- cv[cv$engine_class == "UNRESOLVED", ]

## ---- (1) Yin's DCAN table, 2 <= v <= 25 ----
ccl <- cb[cb$Source == "Cohen-Colbourn-Ling", ]
cm4 <- cb[cb$Source == "Colbourn-Martirosyan-TVT-Walker" & cb$t == 4, ]
KMAX <- max(floor(c(ccl$k, cm4$k) / 2))
cat("\n== (1) DCAN from Yin 2003 ==\n")
cat("k range the rows need: CCL k-ary Roux, k' from 2 to", max(floor(ccl$k / 2)), "(k_row", min(ccl$k), "to", max(ccl$k), ");",
    "CMTW strength 4, k' = k/v from", min(cm4$k[cm4$k %% cm4$v == 0] / cm4$v[cm4$k %% cm4$v == 0]), "to", max(cm4$k[cm4$k %% cm4$v == 0] / cm4$v[cm4$k %% cm4$v == 0]),
    "in the vk forms and k/2 up to", max(cm4$k) / 2, "in the 2k forms; table built for k = 2 ..", KMAX, "\n")
tab <- NULL
for (v in 2:25) {
    f <- ppfac(v); K1 <- min(f); grp <- paste(sprintf("EA(%d)", f), collapse = "+")
    zv <- all(sapply(f, function(q) { p <- 2; while (q %% p != 0) p <- p + 1; q == p }))
    for (k in 2:KMAX) {
        n <- NA; src <- NA; g <- NA; exact <- NA
        if (k <= K1) { n <- v; src <- "Lemma 3.1 (difference matrix, n = q)"; g <- grp; exact <- TRUE }
        if (v %% 4 == 2 && k %in% 3:4) {
            n <- v + 1; exact <- TRUE
            if (v == 2) { src <- if (k == 4) "Example 1.1, DCA(4,3;2)" else "Example 1.1 minus a row"; g <- "Z_2" }
            else if (v %in% c(6, 18)) { src <- if (k == 4) sprintf("Lemma 3.4, DCA(4,%d;%d)", v + 1, v) else "Lemma 3.4 minus a row"; g <- sprintf("Z_%d", v) }
            else if (v == 10) { src <- "Lemma 3.4, DCA(5,11;10) minus rows"; g <- "Z_10" }
            else { src <- if (k == 4) "Theorem 3.2, DCA(4,q+1;q)" else "Theorem 3.2 minus a row"; g <- sprintf("Z_2+EA(%d) = Z_%d", v / 2, v) }
        }
        if (v == 10 && k == 5) { n <- 11; src <- "Lemma 3.4, DCA(5,11;10)"; g <- "Z_10"; exact <- TRUE }
        if (!is.na(n)) tab <- rbind(tab, data.frame(v = v, k = k, group = g, over_Zv = (k <= K1 && zv) || grepl("^Z_", g), n_yin = n, DCAN_cmtw = n - 1, exact = exact, source = src, stringsAsFactors = FALSE))
    }
}
write.csv(tab, "data/dcan_table.csv", row.names = FALSE)
cov <- aggregate(k ~ v, tab, max); names(cov)[2] <- "kmax_yin"
cov$DCAN_at_kmax <- sapply(cov$v, function(v) tab$DCAN_cmtw[tab$v == v & tab$k == cov$kmax_yin[cov$v == v]])
cov$over_Zv_all <- sapply(cov$v, function(v) all(tab$over_Zv[tab$v == v]))
cat("entries with a Yin bound:", nrow(tab), "(of", 24 * (KMAX - 1), "cells); all exact (lower bound met):", all(tab$exact), "\n")
cat("largest k with a bound, per v (DCAN in the CMTW convention, nonzero differences):\n"); print(cov, row.names = FALSE)
dcan <- function(k, v) { i <- which(tab$v == v & tab$k == k); if (length(i)) tab$DCAN_cmtw[i] else NA }

## ---- (2) Cohen-Colbourn-Ling, CMTW Theorem 3.3: CAN(3, k l, v) <= CAN(3, k, v) + CAN(3, l, v) + CAN(2, l, v) DCAN(2, k, v) ----
cat("\n== (2) Cohen-Colbourn-Ling:", nrow(ccl), "plain rows, t = 3 ==\n")
ccl$N_pred <- NA; ccl$route <- NA; ccl$fit_name <- NA; ccl$fit_value <- NA
diag <- NULL
for (i in seq_len(nrow(ccl))) { v <- ccl$v[i]; k <- ccl$k[i]; N <- ccl$N[i]
    N3 <- NK[[paste(3, v)]]; N2 <- NK[[paste(2, v)]]
    kp <- 2:(k - 1); l <- ceiling(k / kp); ok <- l >= 2 & kp <= length(N3) & l <= length(N3) & l <= length(N2)
    kp <- kp[ok]; l <- l[ok]; a <- N3[kp]; b <- N3[l]; c2 <- N2[l]
    ## the law with Yin's DCAN
    D <- sapply(kp, dcan, v = v); pred <- a + b + c2 * D
    if (any(!is.na(pred))) { j <- which.min(pred); ccl$N_pred[i] <- pred[j]; ccl$route[i] <- sprintf("3.3 k'=%d l=%d D=%d", kp[j], l[j], D[j]) }
    ## the integer Q needed by each factorisation (plain CAN(2, l, v) and CAN(2, l, v) - 1, the "equal pairs not needed" reading)
    Q1 <- (N - a - b) / c2; Q2 <- (N - a - b) / (c2 - 1)
    h1 <- which(Q1 == round(Q1) & Q1 >= v - 1); h2 <- which(Q2 == round(Q2) & Q2 >= v - 1)
    if (length(h1)) diag <- rbind(diag, data.frame(v = v, k = k, N = N, kp = kp[h1], l = l[h1], variant = "CAN2", Q = Q1[h1], yin = sapply(kp[h1], dcan, v = v), ca_bound = N2[kp[h1]] - 1))
    if (length(h2)) diag <- rbind(diag, data.frame(v = v, k = k, N = N, kp = kp[h2], l = l[h2], variant = "CAN2-1", Q = Q2[h2], yin = sapply(kp[h2], dcan, v = v), ca_bound = N2[kp[h2]] - 1))
}
ccl$tier <- ifelse(is.na(ccl$N_pred), "OPEN", ifelse(ccl$N == ccl$N_pred, "RECURSIVE", ifelse(ccl$N > ccl$N_pred, "RECURSIVE_STALE", "OPEN")))
cat("law evaluable with Yin's DCAN (some k' <= Yin's coverage):", sum(!is.na(ccl$N_pred)), "rows; exact", sum(ccl$tier == "RECURSIVE"),
    "; record above", sum(ccl$tier == "RECURSIVE_STALE"), "; record below the Yin law", sum(!is.na(ccl$N_pred) & ccl$N < ccl$N_pred), "\n")
gap <- (ccl$N_pred - ccl$N) / ccl$N; cat("record below the Yin law by a median", sprintf("%.0f%%", 100 * median(gap, na.rm = TRUE)), "(min", sprintf("%.0f%%", 100 * min(gap, na.rm = TRUE)), ", max", sprintf("%.0f%%", 100 * max(gap, na.rm = TRUE)), ") of N\n")
key <- paste(diag$v, diag$k)
cat("integer-Q diagnostic (Q the DCAN(2, k', v) that would make some factorisation exact, Q >= v - 1):\n")
cat("  rows with some integer Q: with CAN(2,l,v)", length(unique(key[diag$variant == "CAN2"])), "; with CAN(2,l,v) - 1", length(unique(key[diag$variant == "CAN2-1"])),
    "; either", length(unique(key)), "; neither", nrow(ccl) - length(unique(key)), "of", nrow(ccl), "\n")
inyin <- diag[!is.na(diag$yin), ]
cat("  exact factorisations with k' inside Yin's coverage:", nrow(inyin), "on", length(unique(paste(inyin$v, inyin$k))), "rows; of those Q == Yin", sum(inyin$Q == inyin$yin), ", Q < Yin (impossible, Yin's values are exact)", sum(inyin$Q < inyin$yin), ", Q > Yin", sum(inyin$Q > inyin$yin), "\n")
rows_only_out <- setdiff(unique(key), unique(paste(inyin$v, inyin$k)))
cat("  rows whose exact factorisations all need k' beyond Yin's coverage (no Yin bound at all):", length(rows_only_out), "\n")
nf <- table(key); cat("  candidate exact factorisations per such row: median", median(nf), ", max", max(nf), "(chance hits in a search this wide; nothing admitted)\n")
## what DCAN the record would need at Yin's own k' (the k' that minimises the Yin law): below Yin's exact value on every row
need <- t(sapply(seq_len(nrow(ccl)), function(i) { v <- ccl$v[i]; k <- ccl$k[i]; N3 <- NK[[paste(3, v)]]; N2 <- NK[[paste(2, v)]]
    kp <- as.integer(sub("^3.3 k'=([0-9]+).*", "\\1", ccl$route[i])); l <- ceiling(k / kp); D <- dcan(kp, v)
    c(kp = kp, D_yin = D, Q_needed = (ccl$N[i] - N3[kp] - N3[l]) / N2[l]) }))
cat("  at the k' of the Yin law, the DCAN the record would need is below Yin's (exact) value on", sum(need[, "Q_needed"] < need[, "D_yin"]), "of", nrow(ccl),
    "rows, by a median of", sprintf("%.1f", median(need[, "D_yin"] - need[, "Q_needed"])), "rows of the DCA (Yin's value there is", sprintf("%.0f", median(need[, "D_yin"])), "at the median);",
    "since Yin's values meet the lower bound, no DCA can supply that; the record's k' lies beyond Yin's coverage on every row\n")
cat("  distinct Q per (v, k') among exact factorisations with >= 3 rows (a consistent value would read as one DCAN entry):\n")
ag <- aggregate(Q ~ v + kp + variant, diag, function(x) length(unique(x))); agn <- aggregate(Q ~ v + kp + variant, diag, length); ag$rows <- agn$Q
ag <- ag[ag$rows >= 3, ]; cat("    (v, k', variant) triples with >= 3 rows:", nrow(ag), "; with a single Q value:", sum(ag$Q == 1), "\n")
if (any(ag$Q == 1)) print(ag[ag$Q == 1, ], row.names = FALSE)
ccl$family <- "Cohen-Colbourn-Ling"

## ---- (3) CMTW strength 4 ----
cat("\n== (3) Colbourn-Martirosyan-TVT-Walker strength 4:", nrow(cm4), "plain rows ==\n")
cm4$pp <- sapply(cm4$v, is_pp)
cm4$N_pred <- NA; cm4$route <- NA; cm4$fit_name <- NA; cm4$fit_value <- NA; cm4$tier <- "OPEN"
h <- cm4$k / 2
e4h <- mapply(nk, 4, h, cm4$v); e3h <- mapply(nk, 3, h, cm4$v); e2h <- mapply(nk, 2, h, cm4$v)
## (3a) Lemma 4.8 with CODN(2, v, v) = v^2 - v (v a prime power, k even): N = CAN(4,h,v) + (v-1) CAN(3,h,v) + v^2 CODN(2,h,v); Corollary 4.9 is CODN(2,h,v) = CAN(2,h,v) - 1
ia <- cm4$k %% 2 == 0 & cm4$pp
q48 <- (cm4$N - e4h - (cm4$v - 1) * e3h) / cm4$v^2
p49 <- e4h + (cm4$v - 1) * e3h + cm4$v^2 * (e2h - 1)
cat("(3a) Lemma 4.8 / Corollary 4.9, v prime power, k even:", sum(ia), "rows; Corollary 4.9 exact", sum(cm4$N[ia] == p49[ia], na.rm = TRUE), ", record above it", sum(cm4$N[ia] > p49[ia], na.rm = TRUE), ", below it", sum(cm4$N[ia] < p49[ia], na.rm = TRUE), "\n")
int48 <- ia & q48 == round(q48) & !is.na(q48)
ok48 <- int48 & q48 >= cm4$v^2 - cm4$v & q48 <= e2h - 1
cat("     integer CODN(2, k/2, v) fitted:", sum(int48), "rows; inside [v^2 - v, CAN(2,k/2,v) - 1]:", sum(ok48), "\n")
x <- cm4[ok48, ]; x$h <- x$k / 2; x$CODN_fit <- q48[ok48]; x$e2 <- e2h[ok48]; x$below_CAN2_minus_1 <- x$e2 - 1 - x$CODN_fit
print(x[order(x$v, x$k), c("v","k","h","N","CODN_fit","e2","below_CAN2_minus_1")], row.names = FALSE)
cm4$fit_name[ok48] <- "CODN(2,k/2,v) via Lemma 4.8"; cm4$fit_value[ok48] <- q48[ok48]; cm4$route[ok48] <- "4.8"
cnt <- aggregate(k ~ v + q, data.frame(v = x$v, q = x$CODN_fit, k = x$k), length)
cons <- cnt[cnt$k >= 3, ]
cat("     one fitted value shared by >= 3 rows at the same v:", nrow(cons), "cases\n"); if (nrow(cons)) print(cons, row.names = FALSE)
for (j in seq_len(nrow(cons))) { sel <- ok48 & cm4$v == cons$v[j] & q48 == cons$q[j]; cm4$tier[sel] <- "RECURSIVE_TENTATIVE"; cm4$N_pred[sel] <- cm4$N[sel]; cm4$route[sel] <- sprintf("4.8 with CODN(2,k/2,%d) = %d read off the record", cons$v[j], cons$q[j]) }
## second reading of the same residual: Theorem 4.7 with its pair ingredient reduced to non-constant pairs, R = CODN(2, k/2, v^2); at v = 3 the table holds CAN(2, k/2, 9)
R <- cm4$N - e4h - (cm4$v - 1) * e3h
e2sq <- mapply(function(h, v) if (v^2 <= 25) nk(2, h, v^2) else NA, h, cm4$v)
i3 <- ia & cm4$v == 3
cat("     second reading at v = 3: R = N - CAN(4,k/2,3) - 2 CAN(3,k/2,3) against CAN(2,k/2,9) (Theorem 4.7 is R = CAN(2,k/2,9); 4.13's proof uses CODN(2,k,v^2) <= CAN(2,k,v^2) - 1):\n")
print(data.frame(k = cm4$k[i3], h = h[i3], R = R[i3], CAN2_h_9 = e2sq[i3], R_minus_CAN2 = R[i3] - e2sq[i3]), row.names = FALSE)
cat("     R = CAN(2,k/2,9) - 9 on", sum(R[i3] == e2sq[i3] - 9), "of", sum(i3), "v = 3 rows: the 8 RECURSIVE_TENTATIVE rows at v = 3 read equally as CODN(2,k/2,3) = 32 (Lemma 4.8) or as CODN(2,k/2,9) = CAN(2,k/2,9) - 9 (Theorem 4.7 with a strength-2 array of 9 constant rows deleted); the record does not separate the two.\n")
## observation on the k = 2v rows, v a prime power: R against Lemma 4.8 with CODN(2,v,v) = v^2 - v in both places
i2v <- ia & cm4$k == 2 * cm4$v
cat("     k = 2v rows (v prime power):", sum(i2v), "; R - v^2 (v^2 - v) =", paste(R[i2v] - cm4$v[i2v]^2 * (cm4$v[i2v]^2 - cm4$v[i2v]), collapse = ", "), "at v =", paste(cm4$v[i2v], collapse = ", "),
    "; the record is Lemma 4.8 with CODN(2,v,v) = v^2 - v for both CODN terms, less v - 1 (R = (v-1)(v^3-1)); an observation, no theorem read gives the v - 1, not admitted\n")
## (3b) Theorem 4.13 / Corollaries 4.14, 4.15 (v >= 4 prime power, v | k), k' = k/v
ib <- cm4$pp & cm4$v >= 4 & cm4$k %% cm4$v == 0
kk <- cm4$k / cm4$v
e4k <- mapply(nk, 4, kk, cm4$v); e3k <- mapply(nk, 3, kk, cm4$v); e2k <- mapply(nk, 2, kk, cm4$v)
Dy <- mapply(dcan, kk, cm4$v)
p415 <- e4k + (cm4$v - 1) * e3k + (cm4$v^3 - cm4$v^2) * Dy + (cm4$v^2 + cm4$v) * e2k - 1 + cm4$v^4 - 2 * cm4$v^2
## Theorem 4.13 itself: CODN(2, k', v^2) <= CODN(2, v^2, v^2) <= v^4 - v^2 for k' <= v^2 (CMTW's CODN(2, w, w) <= w^2 - w for a prime power w, in its proof of
## Corollary 4.9, applied at w = v^2, and a COD is monotone in k); v^4 - v^2 is also the count lower bound, so the ingredient is exact there
p413 <- e4k + (cm4$v - 1) * e3k + (cm4$v^3 - cm4$v^2) * Dy + ifelse(kk <= cm4$v^2, cm4$v^4 - cm4$v^2, NA) + cm4$v^4 - cm4$v^2
cat("(3b) Theorems 4.13-4.15, v >= 4 prime power, v | k:", sum(ib), "rows; k' = k/v inside Yin's coverage (k' <= v):", sum(ib & !is.na(Dy)), "\n")
sel <- ib & !is.na(Dy)
if (any(sel)) { y <- cm4[sel, ]; y$kk <- kk[sel]; y$D_yin <- Dy[sel]; y$pred_413 <- p413[sel]; y$pred_415 <- p415[sel]; print(y[, c("v","k","kk","N","D_yin","pred_413","pred_415")], row.names = FALSE)
    cm4$N_pred[sel] <- p413[sel]; cm4$route[sel] <- "4.13 with Yin D = v-1 (k' <= v) and CODN(2,k',v^2) = v^4 - v^2"
    cm4$tier[sel] <- ifelse(cm4$N[sel] == p413[sel], "RECURSIVE", ifelse(cm4$N[sel] > p413[sel], "RECURSIVE_STALE", "OPEN"))
    cat("     Theorem 4.13 with Yin's D and the Bush CODN: exact", sum(cm4$tier[sel] == "RECURSIVE"), "(the k = v^2 rows), record below it", sum(cm4$N[sel] < p413[sel]), "(the k = 2v rows, which are 2k rows, see 3a); Corollary 4.15 exact", sum(cm4$N[sel] == p415[sel]), "\n") }
D415 <- (cm4$N - e4k - (cm4$v - 1) * e3k - (cm4$v^2 + cm4$v) * e2k + 1 - cm4$v^4 + 2 * cm4$v^2) / (cm4$v^3 - cm4$v^2)
i415 <- ib & D415 == round(D415) & D415 >= cm4$v - 1 & !is.na(D415)
cat("     Corollary 4.15 (all ingredients in the table but DCAN): integer DCAN(2,k',v) >= v - 1 on", sum(i415), "of", sum(ib), "rows\n")
cm4$fit_name[i415 & is.na(cm4$fit_name)] <- "DCAN(2,k/v,v) via Corollary 4.15"; cm4$fit_value[i415 & is.na(cm4$fit_value)] <- D415[i415 & is.na(cm4$fit_value)]
S <- cm4$N - e4k - (cm4$v - 1) * e3k - cm4$v^4 + cm4$v^2
cat("     Theorem 4.13: the record fixes only S = (v^3 - v^2) DCAN(2,k',v) + CODN(2,k',v^2) = N - CAN(4,k',v) - (v-1) CAN(3,k',v) - v^4 + v^2;\n",
    "    CODN(2,k',v^2) is not a table quantity for v >= 6 (v^2 > 25) and DCAN(2,k',v) has no Yin bound at these k'; underdetermined.\n",
    "    S per v (rows, distinct S, S divisible by v^2, S at the floor D = v - 1 gives CODN(2,k',v^2) = S - (v^3 - v^2)(v - 1)):\n")
z <- cm4[ib, ]; z$S <- S[ib]; z$kk <- kk[ib]
sv <- do.call(rbind, lapply(split(z, z$v), function(d) data.frame(v = d$v[1], rows = nrow(d), kk_min = min(d$kk), kk_max = max(d$kk), distinct_S = length(unique(d$S)), S_div_v2 = sum(d$S %% d$v[1]^2 == 0), S_min = min(d$S), S_max = max(d$S), CODN_floor_min = min(d$S) - (d$v[1]^3 - d$v[1]^2) * (d$v[1] - 1))))
print(sv, row.names = FALSE)
cat("     (S < 0 at k' = 2 means the row is not of this form at all; those are 2k rows tested in (3a).)\n")
## (3c) Theorem 4.11 / Corollary 4.12 (v = 3, 3 | k): N = CAN(4,k',3) + 2 CAN(3,k',3) + 18 DCAN(2,k',3) + CAN(2,k',9) - 1 + 18
ic <- cm4$v == 3 & cm4$k %% 3 == 0
e29 <- mapply(nk, 2, kk, 9)
D412 <- (cm4$N - e4k - 2 * e3k - e29 + 1 - 18) / 18
cat("(3c) Corollary 4.12, v = 3, 3 | k:", sum(ic), "rows; k' = k/3:", paste(kk[ic], collapse = ", "), "; DCAN(2,k',3) needed:", paste(sprintf("%.2f", D412[ic]), collapse = ", "), "; integer:", sum(D412[ic] == round(D412[ic])), "(Yin covers k' <= 3 only)\n")
## (3d) Lemma 4.8 for non-prime-power v with CODN(2, v, v) at its table bound CAN(2, v, v) - 1: N = CAN(4,h,v) + (v-1) CAN(3,h,v) + (CAN(2,v,v) - 1 + v) CODN(2,h,v)
id <- cm4$k %% 2 == 0 & !cm4$pp
cvv <- sapply(cm4$v, function(v) nk(2, v, v))
q48n <- (cm4$N - e4h - (cm4$v - 1) * e3h) / (cvv - 1 + cm4$v)
okn <- id & q48n == round(q48n) & q48n >= cm4$v^2 - cm4$v & q48n <= e2h - 1 & !is.na(q48n)
cat("(3d) Lemma 4.8, v not a prime power, k even, with CODN(2,v,v) = CAN(2,v,v) - 1:", sum(id), "rows; integer CODN(2,k/2,v) inside its bounds:", sum(okn), "(two unknown CODN values; reported, not tiered)\n")
if (any(okn)) { w <- cm4[okn, ]; w$CODN_fit <- q48n[okn]; w$e2 <- e2h[okn]; print(w[, c("v","k","N","CODN_fit","e2")], row.names = FALSE) }
cm4$fit_name[okn & is.na(cm4$fit_name)] <- "CODN(2,k/2,v) via Lemma 4.8 with CODN(2,v,v) = CAN(2,v,v) - 1"; cm4$fit_value[okn & is.na(cm4$fit_value)] <- q48n[okn & is.na(cm4$fit_value)]
## (3e) the rest: Theorem 4.1 products with DCAN, CODN(3, ., v) and QCAN, none in the table
ie <- !(ia | ib | ic | id)
cat("(3e) rows reachable only through Theorem 4.1 / Corollaries 4.3, 4.6 (k l products with DCAN, CODN(3,.,v), QCAN; no table quantity):", sum(ie), "\n")
cm4$route[is.na(cm4$route)] <- ifelse(ia[is.na(cm4$route)], "4.8 (no integer CODN)", ifelse(ib[is.na(cm4$route)], "4.13 (underdetermined)", ifelse(ic[is.na(cm4$route)], "4.12 (no integer DCAN)", ifelse(id[is.na(cm4$route)], "4.8 non-pp (no integer CODN)", "4.1 (no table quantity)"))))
cm4$family <- "Colbourn-Martirosyan-TVT-Walker"
cat("CMTW strength 4 by tier:\n"); print(table(cm4$tier))

## ---- output ----
out <- rbind(ccl[, c("family","t","v","k","N","Source","route","N_pred","fit_name","fit_value","tier")], cm4[, c("family","t","v","k","N","Source","route","N_pred","fit_name","fit_value","tier")])
cat("\n== all rows by family and tier ==\n"); print(table(out$family, out$tier))
m <- match(paste(u$t, u$v, u$k, u$Source), paste(out$t, out$v, out$k, out$Source))
cat("unresolved entries covered:", sum(!is.na(m)), "\n"); print(table(out$family[m[!is.na(m)]], out$tier[m[!is.na(m)]]))
write.csv(out, "data/arith_formula_dcan.csv", row.names = FALSE)
cat("\nDCAN RUN DONE\n")
