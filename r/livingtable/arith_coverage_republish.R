## arith_coverage_republish.R - the coverage accounting
## republished with the recursive classes counted separately from the
## verified classes, never blended. Reads data/engine_coverage.csv (the
## engine's accounting from engine_coverage.R: VERIFIED / VERIFIED_IMPROVED /
## SEARCH / UNRESOLVED) and data/arith_tally.csv (the classes of the
## UNRESOLVED set) and writes data/engine_coverage_v2.csv with one class
## per entry, no omissions. The one distinction that matters is between
## an array that exists and has been checked (VERIFIED, VERIFIED_IMPROVED)
## and a size that only a construction accounts for (the RECURSIVE family).
## Run from r/livingtable/ (paths adjusted for the repository layout):
##   Rscript arith_coverage_republish.R | tee results/arith_coverage_republish_result.txt
cv <- read.csv("data/engine_coverage.csv", stringsAsFactors = FALSE)
ta <- read.csv("data/arith_tally.csv", stringsAsFactors = FALSE)
key <- function(d) paste(d$t, d$v, d$k, d$Source)
cv$tier <- cv$engine_class
m <- match(key(cv), key(ta))
cv$tier[!is.na(m)] <- ta$arith_tier[m[!is.na(m)]]
cv$arith_family <- NA; cv$arith_family[!is.na(m)] <- ta$arith_family[m[!is.na(m)]]
stopifnot(sum(!is.na(m)) == nrow(ta))
write.csv(cv[, c("t","v","k","N","Source","status","engine_class","tier","arith_family")], "data/engine_coverage_v2.csv", row.names = FALSE)
n <- nrow(cv)
lab <- c(VERIFIED = "rebuilt by CAs and checked by caverify, record reproduced",
         VERIFIED_IMPROVED = "rebuilt by CAs and checked by caverify, record beaten",
         RECURSIVE = "a construction reproduces the size exactly from table ingredients, nothing built (claims)",
         RECURSIVE_TENTATIVE = "the same, reading possibly coincidental or an ingredient outside the table",
         RECURSIVE_STALE = "the construction gives fewer rows than the entry: stale-record leads",
         RECURSIVE_BELOW = "record below the law: better ingredient reading exists",
         POST_OPTIMIZED = "a construction started the array and a post-optimization search finished it; the law gives the size before the search",
         SEARCH = "search-tagged, no table ingredient; not rebuilt here",
         DIRECT_ONLY = "published one-off construction or search result, no table ingredient, no builder",
         OPEN = "attempted, construction not recovered (ingredients the tables do not publish)")
cat("COVERAGE ACCOUNTING v2,", n, "entries, no omissions:\n\n")
for (c in names(lab)) { k <- sum(cv$tier == c); cat(sprintf("  %-20s %5d  (%5.1f%%)  %s\n", c, k, 100 * k / n, lab[c])) }
cat("\nsanity: classes sum to", sum(cv$tier %in% names(lab)), "of", n, "\n")
ver <- sum(cv$tier %in% c("VERIFIED","VERIFIED_IMPROVED")); srch <- sum(cv$tier == "SEARCH"); rec <- sum(cv$tier == "RECURSIVE")
cat(sprintf("\nverified (rebuilt and checked): %d (%.1f%%); search-tagged, no ingredients, not rebuilt: %d (%.1f%%); RECURSIVE claims with a calibrated law: %d (%.1f%%)\n",
    ver, 100 * ver / n, srch, 100 * srch / n, rec, 100 * rec / n))
cat(sprintf("entries with no handle yet (OPEN): %d (%.1f%%); never propagable (POST_OPTIMIZED plus DIRECT_ONLY): %d (%.1f%%)\n",
    sum(cv$tier == "OPEN"), 100 * sum(cv$tier == "OPEN") / n,
    sum(cv$tier %in% c("POST_OPTIMIZED","DIRECT_ONLY")), 100 * sum(cv$tier %in% c("POST_OPTIMIZED","DIRECT_ONLY")) / n))
cat("\nby strength, share with a handle (verified, search or RECURSIVE, each counted apart above):\n")
print(round(tapply(cv$tier %in% c("VERIFIED","VERIFIED_IMPROVED","SEARCH","RECURSIVE"), cv$t, mean), 3))
cat("\nREPUBLISH DONE\n")
