## arith_formula_cmmssy.R - the partitioned-product families at
## strength 2: "Direct product generalized" (1,573 rows, 1,541 open),
## the open "Direct product" rows (320), and "PCAxPCA" / "PCAx2PCA"
## (515 rows, 6 with a postop suffix). The paper is Colbourn,
## Martirosyan, Mullen, Shasha, Sherwood, Yucas, "Products of mixed
## covering arrays of strength two", J. Combin. Designs 14 (2006)
## 124-138, read BY EYE from the pdf on 2026-09-12 (all 15 pages).
## Theorem numbers below are the paper's own.
##   Theorem 3.1  don't-care profile product: A an MCA(N; 2, k, (v_i))
##                with profile (d_1..d_k), B_i an MCA(M_i; 2, l_i, ...)
##                with w_ij <= v_i; then T = N + max_i (M_i - d_i) rows
##                on sum l_i columns.
##   Theorem 3.2  PCA(N; 2, (k1, k2), v) x SCA(M; 2, (l1, l2), v)
##                -> PCA(N + M - v; 2, (k1 l1, k1 l2 + k2 l1), v).
##   Theorem 3.3  when the SCA's block B1 holds a v x eta subarray of
##                column permutations, the result is a
##                PCA(N + M - v; 2, (eta (k1 + k2), (l1 - eta)(k1 + k2) + k1 l2), v).
##                (Read by eye: the second part is k1 l2, so the total is
##                l1 (k1 + k2) + k1 l2, the same total as Theorem 3.2.)
##   Lemma 3.4    q a prime power, r >= 0: SCA((r+1) q^2 - r q; 2, (q^(r+1), (r+1) q^r), q)
##                (Theorem 3.2 iterated r times with the SCA(q^2; 2, (q, 1), q)).
##   Lemma 3.5    same rows, SCA((r+1) q^2 - r q; 2, ((q+1) D_{r+1,q}, q D_{r,q}), q),
##                D_{0,t} = 0, D_{1,t} = 1, D_{r+1,t} = t D_{r,t} + t D_{r-1,t}
##                (Theorem 3.3 iterated with eta = q inside the OA's B1).
##   Theorem 4.1  direct construction with a binary code D(r, M):
##                CA(r (N - v) + v; 2, k1^r + sum_j k1^{x_j} k2^{y_j}, v) from an SCA(N; 2, (k1, k2), v).
##   Theorem 4.2  r >= s >= 1, q a prime power: SCA((r+1) q^2 - r q; 2, (q^(r+1), C(r+1, s) q^(r+1-s)), q).
##   Section 5    a (g, l)-distinct cover starter gives SCA(l (g-1) + g; 2, (l, 1), g);
##                listed for (5, 5..10), (3, l >= 3), (4, l >= 6), (6, 8..12),
##                (7, 7), (7, 9..13), (8, 11..14), (9, 12..15); Lemma 5.2: (p, p), p >= 3 prime.
## The package (CAs 0.24, productPCA) implements Theorem 3.2 with BOTH
## factors allowed to be PCAs (the later generalization it cites), with
##   rows N + M - v, k1' = k1 l1, k' = k1 l1 + k1 l2 + k2 l1,
## and CAs::PCAcat holds 447 product recipes with their (N, k, k1).
## Part 1 below re-derives every PCAcat (N, k, k1) from the ingredients'
## (N, k, k1) and that column law alone: the calibration of the law.
## Part 2 builds a bounded closure of Theorems 3.2 and 3.3 over a base
## set per v (OA SCAs, PCAcat rows, the package's cover-starter and
## small-array ingredients, the paper's own extra SCAs) and asks, for
## each target row, whether some closure array has N' <= N, k' >= k.
## Part 3 is the plain Theorem 3.1 reading on the open "Direct product"
## rows: N = N1 + N2 - d with d in 0..v, N1, N2 the best pair of eCAN.
## Nothing in the tags gives the record's own partitions (k1, k2), so
## a miss here is a miss of THIS base set, not a refutation.
## Counts (this run): PCAcat 447 of 447 exact on (N, k, k1). Closure:
## PCAx 545 rows, 44 exact (27 already engine-VERIFIED, 17 new
## RECURSIVE), 443 reached only above the record, 58 not reached, 0
## where the closure beats the record; 362 rows sit exactly on the
## N + M - v floor (313 of them, non-postop and not closure-exact,
## RECURSIVE_TENTATIVE under the plain best-pair reading), 182 above it,
## 6 postop POST_OPTIMIZED. "Direct product generalized" 1,573 rows:
## 0 exact, 772 above, 801 not reached; 1,522 are BELOW the N + M - v
## floor, so they are not Theorem 3.2 / 3.3 / 4.1 products of two
## table-size arrays under any partition: OPEN. "Direct product"
## 545 rows: 5 exact (the k = 20000 cap rows, engine-VERIFIED), 360
## above, 180 not reached; of the 320 open rows 230 are below the
## floor, 90 have d = S_min - N in 2..v-1, none at d = v: OPEN.
## Bounds: up to 5 products, N' <= max target N per v, arrays with
## k >= max target k terminal; total runtime about one minute.
## Outputs: data/arith_formula_cmmssy.csv holds the 545 PCAx rows only
## (family "PCAx"; the Direct product groups keep the keys and tiers of
## arith_formula_dp_table.csv and are reported here only), and
## data/arith_pcax_recipes.csv holds the 44 exact PCAx matches as two table
## lookups (2, w, v) for law_pcax in arith_laws.R; on all 44 (17 of them
## unresolved) both ingredient sizes equal eCAN(2, w, v) at their widths.
## Run from r/livingtable/ (paths adjusted for the repository layout), after
## the other family scripts and before arith_tally.R; it reads data/arith_tally.csv
## as shipped to mark which rows were open before this pass:
##   Rscript arith_formula_cmmssy.R | tee results/arith_formula_cmmssy_result.txt
t0 <- proc.time()[3]
suppressMessages(library(CAs)); data(colbournBigFrame); cb <- colbournBigFrame; data(PCAcat)
ns <- asNamespace("CAs")
is_pp <- function(v) { p <- 2; while (v %% p != 0) p <- p + 1; while (v %% p == 0) v <- v / p; v == 1 }
cv <- read.csv("data/engine_coverage.csv", stringsAsFactors = FALSE)
u <- cv[cv$engine_class == "UNRESOLVED", ]
ta <- read.csv("data/arith_tally.csv", stringsAsFactors = FALSE)

## ======================= Part 1: calibration on PCAcat =======================
leaf_cache <- new.env()
leaf <- function(code) {
    if (!is.null(leaf_cache[[code]])) return(leaf_cache[[code]])
    D <- suppressMessages(eval(parse(text = code)))
    st <- attr(D, "PCAstatus")
    if (!is.list(st)) { p <- is.PCA(D); st <- if (p) attr(p, "PCAstatus") else NULL }   ## as matcheck(PCAcheck = TRUE) in productPCA
    k1 <- if (is.list(st) && !is.null(st$k1)) st$k1 else NA
    ty <- if (is.list(st)) { if (!is.null(st$type)) st$type else st[[1]] } else "none"
    r <- list(N = nrow(D), k = ncol(D), k1 = k1, sca = ty == "SCA", eta = if (grepl("^SCA_Bose", code)) nrow(D) - ncol(D) + 1 else 0, v = length(unique(na.omit(as.vector(D)))), code = code)
    leaf_cache[[code]] <- r; r
}
## the column law (Theorem 3.2, both factors PCAs as the package does):
arith_prod <- function(a, b, v) list(N = a$N + b$N - v, k = a$k1 * b$k1 + a$k1 * (b$k - b$k1) + (a$k - a$k1) * b$k1, k1 = a$k1 * b$k1,
                                     sca = a$sca && b$sca, eta = max(a$eta * b$k1, b$eta * a$k1))
eval_recipe <- function(e, v) {
    if (is.call(e) && identical(e[[1]], as.name("productPCA"))) { stopifnot(length(e) == 3); arith_prod(eval_recipe(e[[2]], v), eval_recipe(e[[3]], v), v) }
    else leaf(paste(deparse(e), collapse = ""))
}
rec <- lapply(seq_len(nrow(PCAcat)), function(i) eval_recipe(parse(text = PCAcat$code[i])[[1]], PCAcat$v[i]))
fac <- lapply(seq_len(nrow(PCAcat)), function(i) { e <- parse(text = PCAcat$code[i])[[1]]; list(eval_recipe(e[[2]], PCAcat$v[i]), eval_recipe(e[[3]], PCAcat$v[i])) })   ## the two top-level factors
pc <- PCAcat[, c("v", "k", "N", "k1", "stage")]
pc$N_law <- sapply(rec, `[[`, "N"); pc$k_law <- sapply(rec, `[[`, "k"); pc$k1_law <- sapply(rec, `[[`, "k1")
pc$sca <- sapply(rec, `[[`, "sca"); pc$eta <- sapply(rec, `[[`, "eta")
pc$f1N <- sapply(fac, function(f) f[[1]]$N); pc$f1k <- sapply(fac, function(f) f[[1]]$k); pc$f2N <- sapply(fac, function(f) f[[2]]$N); pc$f2k <- sapply(fac, function(f) f[[2]]$k)
ok <- pc$N == pc$N_law & pc$k == pc$k_law & pc$k1 == pc$k1_law
cat("== Part 1: PCAcat calibration ==\nPCAcat rows:", nrow(pc), " N exact:", sum(pc$N == pc$N_law), " k exact:", sum(pc$k == pc$k_law),
    " k1 exact:", sum(pc$k1 == pc$k1_law), " all three:", sum(ok), " of", nrow(pc), "\n")
if (any(!ok)) print(pc[!ok, ], row.names = FALSE)
cat("recipes using the one-argument (Bose 2PCA, Theorem 3.3) form of productPCA:", sum(grepl("productPCA\\([^,]*\\)$", PCAcat$code) & !grepl(",", PCAcat$code)), "\n")
cat("recipes by stage:", paste(names(table(pc$stage)), table(pc$stage), sep = ":", collapse = " "), "\n")
L <- do.call(rbind, lapply(ls(leaf_cache), function(n) { r <- leaf_cache[[n]]; data.frame(code = n, N = r$N, k = r$k, k1 = r$k1, sca = r$sca, v = r$v, stringsAsFactors = FALSE) }))
cs <- grepl("^(SCA_LCDST|SCA_MS|CS_CMMSSY)", L$code)
cat("leaf ingredients:", nrow(L), "; cover-starter leaves:", sum(cs), " of which N = (k-1)(v-1) + v and k1 = k - 1 (the Section 5 SCA form):",
    sum(cs & L$N == (L$k - 1) * (L$v - 1) + L$v & L$k1 == L$k - 1), "\n")
cat("time after Part 1:", round(proc.time()[3] - t0), "s\n")

## ======================= targets =======================
tg <- cb[cb$t == 2 & (cb$Source %in% c("Direct product", "Direct product generalized") | grepl("^PCAx", cb$Source)), ]
tg$grp <- ifelse(grepl("^PCAx", tg$Source), "PCAx", ifelse(tg$Source == "Direct product", "Direct product", "Direct product generalized"))
tg$postop <- grepl("postop", tg$Source)
tg$tally <- ta$arith_tier[match(paste(tg$t, tg$v, tg$k, tg$Source), paste(ta$t, ta$v, ta$k, ta$Source))]
tg$open <- is.na(tg$tally) | tg$tally %in% "OPEN"
cat("\n== targets ==\n"); print(table(tg$grp, ifelse(is.na(tg$tally), "not in tally", tg$tally)))
vs <- sort(unique(tg$v))

## ======================= Part 2: base set and closure =======================
## an array is (N, k, k1, eta, sca, flag): eta = width of a v x eta permutation subarray inside B1 (0 = none known);
## flag bits: 1 = uses a package ingredient that is not a PCAcat row or the OA; 2 = uses a paper-only base array
mk <- function(N, k, k1, eta, sca, flag, src, depth = 0, f1N = NA, f1k = NA, f2N = NA, f2k = NA) data.frame(N = N, k = k, k1 = k1, eta = eta, sca = sca, flag = flag, src = src, depth = depth,
    trace = paste0(src, "(", N, ";", k1, "+", k - k1, ")"), f1N = f1N, f1k = f1k, f2N = f2N, f2k = f2k, stringsAsFactors = FALSE)   ## f1, f2: the last product's two factors (size, width)
Dnum <- function(r, t) { d <- c(0, 1); if (r >= 2) for (i in 2:r) d <- c(d, t * d[i] + t * d[i - 1]); d[r + 1] }
stair <- function(v) { x <- cb[cb$t == 2 & cb$v == v, ]; x <- x[order(x$k), ]; kk <- x$k; NN <- rev(cummin(rev(x$N))); function(w) { i <- which(kk >= w); if (!length(i)) NA else NN[i[1]] } }
base_for <- function(v, Nmax) {
    B <- NULL; e <- stair(v)
    ## flag for a package ingredient: 0 when its size N is a table entry (N <= eCAN(2, k, v), the partition being the package's statement), else 1
    pkg <- function(N, k, k1, sca, lab) { tab <- N <= sapply(k, e); mk(N, k, k1, 0, sca, ifelse(tab, 0, 1), ifelse(tab, paste(lab, "table-size"), paste(lab, "NOT table-size"))) }
    if (is_pp(v)) B <- rbind(B, mk(v^2, v + 1, v, v, TRUE, 0, "OA"))
    x <- pc[pc$v == v, ]; if (nrow(x)) B <- rbind(B, mk(x$N, x$k, x$k1, x$eta, x$sca, 0, "PCAcat", 0, x$f1N, x$f1k, x$f2N, x$f2k))
    x <- L[L$v == v & !is.na(L$k1) & !grepl("^SCA_Bose", L$code), ]; if (nrow(x)) B <- rbind(B, pkg(x$N, x$k, x$k1, x$sca, "pkg leaf"))
    ## every cover starter the package holds (all have N = (k-1)(v-1) + v, k1 = k-1, checked on a sample)
    for (nm in c("CMMSSYCombis", "MeagherStevensCombis")) { x <- as.data.frame(get(nm, ns)); x <- x[x$v == v, ]
        if (nrow(x)) B <- rbind(B, pkg(x$N, x$k, x$k - 1, TRUE, paste("pkg", nm))) }
    x <- as.data.frame(get("LCDSTCombis", ns)); x <- x[x$v == v & x$f == 1, ]; if (nrow(x)) B <- rbind(B, pkg(x$N, x$k, x$k - 1, TRUE, "pkg LCDSTCombis"))
    ## paper-only: (4, l)-distinct cover starters, l >= 6 (Section 5), and Theorem 4.2
    if (v == 4) { l <- 6:floor((Nmax - 4) / 3); B <- rbind(B, mk(3 * l + 4, l + 1, l, 0, TRUE, 2, "paper (4,l) starter")) }
    if (is_pp(v)) for (r in 1:20) { N <- (r + 1) * v^2 - r * v; if (N > Nmax) break
        for (s in 1:r) B <- rbind(B, mk(N, v^(r + 1) + choose(r + 1, s) * v^(r + 1 - s), v^(r + 1), 0, TRUE, 2, "paper Thm 4.2")) }
    B <- B[B$N <= Nmax, ]
    B
}
dominated <- function(S) {   ## TRUE where some other row is at least as good in every field
    n <- nrow(S); d <- logical(n); if (n < 2) return(d)
    for (i in seq_len(n)) { j <- which(S$N <= S$N[i] & S$k >= S$k[i] & S$k1 >= S$k1[i] & S$eta >= S$eta[i] & S$sca >= S$sca[i] & bitwAnd(S$flag, bitwNot(S$flag[i])) == 0)
        j <- j[j != i]; if (length(j)) { strict <- S$N[j] < S$N[i] | S$k[j] > S$k[i] | S$k1[j] > S$k1[i] | S$eta[j] > S$eta[i] | S$sca[j] > S$sca[i] | S$flag[j] != S$flag[i]
            if (any(strict) || any(j < i)) d[i] <- TRUE } }
    d
}
closure <- function(v, Nmax, kmax, Dmax = 3) {
    S <- base_for(v, Nmax); if (is.null(S) || !nrow(S)) return(NULL)
    S <- S[!dominated(S), ]
    for (round in seq_len(Dmax)) {
        A <- S[S$k < kmax & S$depth < Dmax, ]; if (!nrow(A)) break
        idx <- expand.grid(i = seq_len(nrow(A)), j = seq_len(nrow(A))); idx <- idx[idx$i <= idx$j & A$depth[idx$i] + A$depth[idx$j] < Dmax, ]
        a <- A[idx$i, ]; b <- A[idx$j, ]
        ## Theorem 3.2 (both factors PCAs, the package's law)
        P <- data.frame(N = a$N + b$N - v, k = a$k1 * b$k1 + a$k1 * (b$k - b$k1) + (a$k - a$k1) * b$k1, k1 = a$k1 * b$k1,
                        eta = pmax(a$eta * b$k1, b$eta * a$k1), sca = a$sca & b$sca, flag = bitwOr(a$flag, b$flag), src = "3.2", depth = a$depth + b$depth + 1,
                        trace = paste0("[", a$trace, " x ", b$trace, "]"), f1N = a$N, f1k = a$k, f2N = b$N, f2k = b$k, stringsAsFactors = FALSE)
        ## Theorem 3.3, second factor an SCA with eta > 0 (ordered pairs); result SCA only when the second factor is the OA
        idx2 <- expand.grid(i = seq_len(nrow(A)), j = which(A$sca & A$eta > 0)); idx2 <- idx2[A$depth[idx2$i] + A$depth[idx2$j] < Dmax, ]
        if (nrow(idx2)) { a <- A[idx2$i, ]; b <- A[idx2$j, ]
            P <- rbind(P, data.frame(N = a$N + b$N - v, k = b$eta * a$k + (b$k1 - b$eta) * a$k + a$k1 * (b$k - b$k1), k1 = b$eta * a$k,
                        eta = a$k1 * b$eta, sca = a$sca & b$src == "OA", flag = bitwOr(a$flag, b$flag), src = "3.3", depth = a$depth + b$depth + 1,
                        trace = paste0("[", a$trace, " x3.3 ", b$trace, "]"), f1N = a$N, f1k = a$k, f2N = b$N, f2k = b$k, stringsAsFactors = FALSE)) }
        P <- P[P$N <= Nmax & P$k1 >= 1, ]; P$k <- pmin(P$k, kmax); P$k1 <- pmin(P$k1, kmax); P$eta <- pmin(P$eta, kmax)
        P <- P[!duplicated(P[, c("N", "k", "k1", "eta", "sca", "flag")]), ]
        S <- rbind(S, P); S <- S[!duplicated(S[, c("N", "k", "k1", "eta", "sca", "flag")]), ]
        S <- S[!dominated(S), ]
    }
    S
}
Dmax <- 5   ## products applied inside the closure (PCAcat rows are already products of up to 5); the sets stay small, so this is not the binding limit
cat("\n== Part 2: closure of Theorems 3.2 and 3.3, up to", Dmax, "products over the base, per v ==\n")
res <- list(); clos <- list()
for (v in vs) {
    tv <- tg[tg$v == v, ]; Nmax <- max(tv$N); kmax <- max(tv$k)
    t1 <- proc.time()[3]; S <- closure(v, Nmax, kmax, Dmax); clos[[as.character(v)]] <- S
    nb <- if (is.null(S)) 0 else sum(S$depth == 0)
    cat(sprintf("v = %2d: targets %4d, Nmax %4d, kmax %5d, base %3d, closure %5d arrays, %3.0f s\n", v, nrow(tv), Nmax, kmax, nb, if (is.null(S)) 0 else nrow(S), proc.time()[3] - t1))
}
## match each target
tg$N_pred <- NA; tg$flag <- NA; tg$route <- NA; tg$trace <- NA; tg$k1_prod <- NA; tg$k_prod <- NA; tg$f1N <- NA; tg$f1k <- NA; tg$f2N <- NA; tg$f2k <- NA
for (i in seq_len(nrow(tg))) { S <- clos[[as.character(tg$v[i])]]; if (is.null(S)) next
    h <- S[S$k >= tg$k[i], ]; if (!nrow(h)) next
    m <- min(h$N); tg$N_pred[i] <- m; hh <- h[h$N == m, ]; j <- which.min(hh$flag); tg$flag[i] <- hh$flag[j]; tg$route[i] <- hh$src[j]; tg$trace[i] <- hh$trace[j]
    tg$k1_prod[i] <- hh$k1[j]; tg$k_prod[i] <- hh$k[j]; tg$f1N[i] <- hh$f1N[j]; tg$f1k[i] <- hh$f1k[j]; tg$f2N[i] <- hh$f2N[j]; tg$f2k[i] <- hh$f2k[j] }
tg$tier <- ifelse(tg$postop, "POST_OPTIMIZED",
           ifelse(is.na(tg$N_pred) | tg$N_pred > tg$N, "OPEN",
           ifelse(tg$N_pred < tg$N, "RECURSIVE_STALE", ifelse(tg$flag == 0, "RECURSIVE", "RECURSIVE_TENTATIVE"))))
tg$reach <- ifelse(is.na(tg$N_pred), "not reached", ifelse(tg$N_pred > tg$N, "reached only above the record", ifelse(tg$N_pred == tg$N, "exact", "closure beats the record")))
cat("\n== closure against the record, all rows in the three tag groups ==\n"); print(table(tg$grp, tg$reach))
cat("\n== the same on the open rows only (OPEN / not in tally) ==\n"); print(table(tg$grp[tg$open], tg$reach[tg$open]))
cat("\n== tiers, all rows ==\n"); print(table(tg$grp, tg$tier))
cat("\nexact matches by flag (0 = OA, PCAcat rows and table-size package ingredients only; 1 = a package ingredient whose size is not a table entry; 2/3 = paper-only base needed):\n")
print(table(tg$grp[tg$reach == "exact"], tg$flag[tg$reach == "exact"]))
ex <- tg[tg$reach == "exact", ]; if (nrow(ex)) { cat("exact matches by v:\n"); print(table(ex$grp, ex$v))
    cat("\nevery exact match with its route (base arrays as src(N;k1+k2); x = Theorem 3.2, x3.3 = Theorem 3.3 with the second factor's eta):\n")
    print(ex[order(ex$grp, ex$v, ex$k), c("v", "k", "N", "Source", "tier", "trace")], row.names = FALSE)
    cat("\nbase arrays other than OA / PCAcat rows used by the exact matches (pkg ... table-size: size a table entry, partition the package's; NOT table-size / paper: RECURSIVE_TENTATIVE):\n")
    bs <- unlist(regmatches(ex$trace, gregexpr("(pkg[A-Za-z -]*|paper[A-Za-z0-9,() .]*)\\([0-9]+;[0-9]+\\+[0-9]+\\)", ex$trace))); print(sort(table(bs), decreasing = TRUE)) }
ab <- tg[tg$reach == "closure beats the record", ]
if (nrow(ab)) { cat("\nrows where the closure is BELOW the record (would be new bounds if the closure were sound; listed for checking):\n"); ab$gap <- ab$N - ab$N_pred; print(ab[, c("v", "k", "N", "Source", "N_pred", "gap", "route", "flag")], row.names = FALSE) }
cat("\nnot reached at all (no closure array with k' >= k at N' <= Nmax(v)), by v:\n"); print(table(tg$v[tg$reach == "not reached"], tg$grp[tg$reach == "not reached"]))
cat("reached only above the record, by v: median gap N_pred - N\n")
ra <- tg[tg$reach == "reached only above the record", ]; if (nrow(ra)) print(aggregate(cbind(gap = N_pred - N) ~ v + grp, ra, function(x) round(median(x))))
cat("time after Part 2:", round(proc.time()[3] - t0), "s\n")

## ======================= Part 3: the N + M - v floor and the Theorem 3.1 don't-care reading =======================
## Every product theorem of the paper (3.2, 3.3, 4.1 at r = 2) has N + M - v rows and at most kA kB columns, so a
## row with N < S_min - v, S_min = min over kA kB >= k of eCAN(2, kA, v) + eCAN(2, kB, v), is not such a product of
## two arrays of table size, whatever their partitions. Theorem 3.1 subtracts min_i d_i instead of v (d_i = the
## don't-care count of column i of the first factor), so it needs d >= S_min - N per column.
cat("\n== Part 3: S_min = best pair eCAN(2, kA, v) + eCAN(2, kB, v) over kA kB >= k; implied d = S_min - N (Theorem 3.1 reading N = N1 + N2 - d) ==\n")
dprof <- function(v, k) { e <- stair(v); best <- Inf
    for (k1 in 2:max(2, floor(sqrt(k)) + 1)) { k2 <- ceiling(k / k1); s <- e(k1) + e(k2); if (!is.na(s) && s < best) best <- s }
    best }
## size consistency: is N + v exactly a pair sum eCAN(2, kA, v) + eCAN(2, kB, v) with kA kB >= k (necessary for Theorem 3.2 / 3.3 on table-size arrays)?
pairsum <- function(v, k, N) { e <- stair(v); for (k1 in 2:max(2, floor(sqrt(k)) + 1)) { k2 <- ceiling(k / k1); if (isTRUE(e(k1) + e(k2) == N + v)) return(TRUE) }
    ## a larger kA with the same eCAN gives the same sum, so the ceiling pairs suffice; also allow any kA up to k with eCAN staircase steps
    x <- cb[cb$t == 2 & cb$v == v, ]; ks <- sort(unique(x$k[x$k <= k])); for (kA in ks) { kB <- ceiling(k / kA); if (kB > k) next; if (isTRUE(e(kA) + e(kB) == N + v)) return(TRUE) }; FALSE }
tg$S_min <- mapply(dprof, tg$v, tg$k); tg$d <- tg$S_min - tg$N
tg$floor <- ifelse(tg$d > tg$v, "below N+M-v floor", ifelse(tg$d == tg$v, "at the floor (plain law)", "above the floor"))
cat("all rows, against the floor S_min - v:\n"); print(table(tg$grp, tg$floor))
tg$pair <- mapply(pairsum, tg$v, tg$k, tg$N)
cat("rows whose N + v is exactly a pair sum eCAN(2, kA, v) + eCAN(2, kB, v), kA kB >= k (size-consistent with Theorem 3.2 on table-size arrays):\n"); print(table(tg$grp, tg$pair))
dp <- tg[tg$grp == "Direct product" & !is.na(tg$tally) & tg$tally == "OPEN" & !tg$postop, ]
cat("\nopen Direct product rows (OPEN in the tally):", nrow(dp), "; implied d = S_min - N:\n"); print(table(dp$d))
cat("d in 0..v (a Theorem 3.1 profile of at most v don't-cares per column; d = v is the plain law):", sum(dp$d >= 0 & dp$d <= dp$v),
    "; d > v (needs more than v don't-cares per column in the first factor):", sum(dp$d > dp$v), "; d < 0 (the best pair beats the record):", sum(dp$d < 0), "\n")
cat("d - v by v on the open Direct product rows (0 = plain law; positive = record below it):\n"); print(table(dp$v, dp$d - dp$v))
dpg <- tg[tg$grp == "Direct product generalized" & !tg$postop, ]
cat("\nthe same on the", nrow(dpg), "Direct product generalized rows: d in 0..v:", sum(dpg$d >= 0 & dpg$d <= dpg$v), "; d > v:", sum(dpg$d > dpg$v), "; d < 0:", sum(dpg$d < 0), "\n")
cat("d - v, quantiles over the rows with d > v:", paste(quantile(dpg$d[dpg$d > dpg$v] - dpg$v[dpg$d > dpg$v]), collapse = " "), "\n")
cat("d - v by v (median) on the rows with d > v:\n"); print(aggregate(cbind(dv = d - v) ~ v, dpg[dpg$d > dpg$v, ], median))
px <- tg[tg$grp == "PCAx", ]
cat("\nPCAx rows:", nrow(px), "; d - v distribution (0 = plain law; negative = above the floor):\n"); print(table(px$d - px$v))
if (any(px$d > px$v)) { cat("PCAx rows below the floor:\n"); print(px[px$d > px$v, c("v", "k", "N", "Source", "S_min", "d")], row.names = FALSE) }
## the plain best-pair reading on the PCAx rows: N = S_min - v exactly. It is the necessary condition above, exact
## on the row, with the partition of the record's own ingredients unpublished: RECURSIVE_TENTATIVE, as the 32 plain-exact
## "Direct product generalized" rows were tiered in arith_formula_dp_table.csv. Not applied to the Direct product
## groups here, which keep that file's treatment (their keys overlap; arith_tally.R requires unique keys).
pl <- tg$grp == "PCAx" & !tg$postop & tg$d == tg$v & tg$tier != "RECURSIVE"
cat("\nPCAx rows at the plain floor and not closure-exact, tiered RECURSIVE_TENTATIVE (plain best-pair reading):", sum(pl), "\n")
tg$route[pl] <- "plain best pair"; tg$N_pred[pl] <- tg$S_min[pl] - tg$v[pl]; tg$tier[pl] <- "RECURSIVE_TENTATIVE"
cat("PCAx rows above the plain floor (record worse than the best pair sum minus v; the partition loss k2 l2 in columns is the likely reason):", sum(tg$grp == "PCAx" & !tg$postop & tg$d < tg$v), "\n")
cat("\n== final tiers, all rows ==\n"); print(table(tg$grp, tg$tier))
cat("== final tiers, PCAx by tag ==\n"); print(table(tg$Source[tg$grp == "PCAx"], tg$tier[tg$grp == "PCAx"]))

## ======================= output =======================
## recipe table for the engine: every exact PCAx match as two table lookups (2, w, v), w the ingredient's width, so that
## ecan(2, w, v) returns its size; a flag per row when the ingredient's size is NOT what the table gives at that width
ex <- tg[tg$grp == "PCAx" & tg$reach == "exact", ]
ex$ing1_ecan <- mapply(function(v, w) stair(v)(w), ex$v, ex$f1k); ex$ing2_ecan <- mapply(function(v, w) stair(v)(w), ex$v, ex$f2k)
ex$ing1_size_is_ecan <- ex$f1N == ex$ing1_ecan; ex$ing2_size_is_ecan <- ex$f2N == ex$ing2_ecan
ex$N_pred_engine <- ex$ing1_ecan + ex$ing2_ecan - ex$v
ex$note <- ifelse(is.na(ex$f1k), "no product: a bare base array",
           ifelse(ex$ing1_size_is_ecan & ex$ing2_size_is_ecan, "both ingredient sizes are the table's eCAN at their widths",
           paste0("size not eCAN at width: ", ifelse(!ex$ing1_size_is_ecan, paste0("ing1 ", ex$f1N, " vs ", ex$ing1_ecan, " "), ""), ifelse(!ex$ing2_size_is_ecan, paste0("ing2 ", ex$f2N, " vs ", ex$ing2_ecan), ""))))
R <- data.frame(t = 2, v = ex$v, k = ex$k, N = ex$N, Source = ex$Source, ing1_t = 2, ing1_w = ex$f1k, ing1_v = ex$v, ing2_t = 2, ing2_w = ex$f2k, ing2_v = ex$v,
                ing1_N = ex$f1N, ing2_N = ex$f2N, ing1_ecan = ex$ing1_ecan, ing2_ecan = ex$ing2_ecan, N_pred = ex$N_pred_engine,
                k1 = ex$k1_prod, k_prod = ex$k_prod, route = ex$route, unresolved = ex$open & !is.na(ex$tally), note = ex$note, trace = ex$trace, stringsAsFactors = FALSE)
R <- R[order(R$v, R$k), ]
write.csv(R, "data/arith_pcax_recipes.csv", row.names = FALSE)
cat("\n== arith_pcax_recipes.csv:", nrow(R), "exact PCAx matches as two table lookups (N_pred = eCAN(2, ing1_w, v) + eCAN(2, ing2_w, v) - v) ==\n")
cat("N_pred equal to the record:", sum(R$N_pred == R$N, na.rm = TRUE), "of", nrow(R), "; both ingredient sizes equal to eCAN at their widths:", sum(R$note == "both ingredient sizes are the table's eCAN at their widths"),
    "; of the", sum(R$unresolved), "unresolved rows:", sum(R$unresolved & R$note == "both ingredient sizes are the table's eCAN at their widths"), "\n")
print(R[, c("v", "k", "N", "Source", "ing1_w", "ing1_N", "ing1_ecan", "ing2_w", "ing2_N", "ing2_ecan", "N_pred", "k1", "k_prod", "route", "unresolved")], row.names = FALSE)
if (any(R$N_pred != R$N | R$note != "both ingredient sizes are the table's eCAN at their widths")) { cat("rows the engine's width lookup would not reproduce:\n"); print(R[R$N_pred != R$N | R$note != "both ingredient sizes are the table's eCAN at their widths", c("v", "k", "N", "note")], row.names = FALSE) }
m <- match(paste(u$t, u$v, u$k, u$Source), paste(tg$t, tg$v, tg$k, tg$Source))
cat("\nunresolved entries in the three groups:", sum(!is.na(m)), "\n"); print(table(tg$grp[m[!is.na(m)]], tg$tier[m[!is.na(m)]]))
cat("rows not in arith_tally.csv (already VERIFIED by the engine):", sum(is.na(tg$tally)), "\n")
## the csv carries the PCAx rows only (family "PCAx"); the Direct product groups keep arith_formula_dp_table.csv's keys and tiers
tg$family <- "PCAx"
out <- tg[tg$grp == "PCAx", c("family", "t", "v", "k", "N", "Source", "N_pred", "tier")]
write.csv(out, "data/arith_formula_cmmssy.csv", row.names = FALSE)
cat("arith_formula_cmmssy.csv:", nrow(out), "PCAx rows written (Direct product rows reported above only)\n")
cat("\ntotal time:", round(proc.time()[3] - t0), "s\nCMMSSY RUN DONE\n")
