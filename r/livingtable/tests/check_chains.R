## check_chains.R - recomputes every derived value from its recorded working.
##
##   Rscript tests/check_chains.R data/arith_chain_<name>.csv [--table=PATH]     (from r/livingtable/)
##
## For each entry in the chain file the size law of its family (arith_laws.R,
## the engine's own laws) is evaluated on the recorded lookup values and
## constant-row credits alone; a lookup the law asks for that is not in the
## working, or a recorded lookup the law never asks for, is an error. For the
## direct product the recorded pair is checked by law_dp's own rule: k1 >= 2,
## k2 = ceiling(k / k1), the credit min(v, c1 + c2) from the pair's recorded
## constant rows (a frozen-record row counts 1 beside an improved one, v when
## both are frozen), and e(2, k1, v) + e(2, k2, v) - credit. Every result must
## equal N_new exactly. Prints one line per failure and ends with CHAIN CHECK: PASS or FAIL
## (exit status 1 on failure).
options(scipen = 99)
args <- commandArgs(TRUE); f <- args[!grepl("^--", args)][1]
source("base_record.R")   ## the same base record as the engine: the CITED rows of the table, fingerprint checked
br <- read_base(table_path(args))
if (!br$ok) { cat(br$why, "\nCHAIN CHECK: FAIL\n"); quit(save = "no", status = 1) }
cb <- br$cb   ## Add a factor chains read cb
source("arith_laws.R")
Mtab <- read.csv("data/arith_power_Mtable.csv", stringsAsFactors = FALSE)
ch <- read.csv(f, stringsAsFactors = FALSE)
if (!nrow(ch)) { cat("no chains in", f, "\nCHAIN CHECK: PASS (empty)\n"); quit(save = "no") }
key <- paste(ch$t, ch$v, ch$k)
bad <- 0; n <- 0
for (e in unique(key)) {
    r <- ch[key == e, ]; n <- n + 1
    t <- r$t[1]; v <- r$v[1]; k <- r$k[1]; fam <- r$family[1]
    if (anyNA(r$N_new) || anyNA(r$value)) { cat(sprintf("(%d,%d,%d) %s: missing value in the working\n", t, v, k, fam)); bad <- bad + 1; next }
    if (r$role[1] == "direct product pair") {
        why <- character(0)
        if (nrow(r) != 2 || any(r$role != "direct product pair") || any(r$ing_t != 2) || any(r$ing_v != v)) why <- c(why, "not one pair at strength 2")
        else { k1 <- r$ing_w[1]; k2 <- r$ing_w[2]; n1 <- r$nconst_credit[1]; n2 <- r$nconst_credit[2]
            if (fam != "Direct product") why <- c(why, "pair recorded for another family")
            if (k1 < 2 || k2 != ceiling(k / k1)) why <- c(why, sprintf("pair (%d, %d) is not k1 >= 2 with k2 = ceiling(k / k1)", k1, k2))
            cc <- if (is.na(n1) && is.na(n2)) v else min(v, ifelse(is.na(n1), 1, n1) + ifelse(is.na(n2), 1, n2))
            if (anyNA(r$pair_credit) || any(r$pair_credit != cc)) why <- c(why, sprintf("credit %s, the rule gives %s", r$pair_credit[1], cc)) }
        if (length(why)) { cat(sprintf("(%d,%d,%d) %s: %s\n", t, v, k, fam, paste(why, collapse = "; "))); bad <- bad + 1; next }
        got <- sum(r$value) - r$pair_credit[1]
    } else {
        missing <- character(0); asked <- character(0)
        ec <- function(tt, w, vv) { asked <<- c(asked, paste(tt, w, vv)); i <- which(r$ing_t == tt & r$ing_w == w & r$ing_v == vv)
            if (!length(i)) { missing <<- c(missing, sprintf("(%d,%d,%d)", tt, w, vv)); return(NA_real_) }; r$value[i[1]] }
        nc <- function(tt, w, vv) { i <- which(r$ing_t == tt & r$ing_w == w & r$ing_v == vv)
            if (!length(i)) return(NA_real_); r$nconst_credit[i[1]] }
        got <- tryCatch(eval_law(fam, t, v, k, r$Source[1], ec, nc, Mtab, list())$N, error = function(z) NA_real_)
        if (length(missing)) { cat(sprintf("(%d,%d,%d) %s: lookups missing from the working: %s\n", t, v, k, fam, paste(unique(missing), collapse = " "))); bad <- bad + 1; next }
        extra <- setdiff(paste(r$ing_t, r$ing_w, r$ing_v), asked)
        if (length(extra)) { cat(sprintf("(%d,%d,%d) %s: lookups in the working that the law does not make: %s\n", t, v, k, fam, paste(extra, collapse = "; "))); bad <- bad + 1; next }
    }
    if (is.na(got) || got != r$N_new[1]) { cat(sprintf("(%d,%d,%d) %s: working gives %s, recorded N_new %s\n", t, v, k, fam, format(got, scientific = FALSE), format(r$N_new[1], scientific = FALSE))); bad <- bad + 1 }
}
cat(sprintf("%s: %d entries, %d recomputed exactly from their working, %d failures\n", f, n, n - bad, bad))
cat("CHAIN CHECK:", if (bad == 0) "PASS" else "FAIL", "\n")
if (bad) quit(save = "no", status = 1)
