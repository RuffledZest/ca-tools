## arith_tally.R - the running tally of the recursive tier: joins every family csv to the
## 9,007 UNRESOLVED entries of engine_coverage.csv and counts the classes (RECURSIVE,
## RECURSIVE_TENTATIVE, RECURSIVE_STALE, RECURSIVE_BELOW, POST_OPTIMIZED, DIRECT_ONLY, OPEN).
## The Add tags come from arith_formula_addn.csv (all n), which
## supersedes the n = 1 rows of arith_formula_small.csv and the
## "Add a factor" rows of arith_families_probe.csv; fused rows come
## from arith_formula_fuse.csv, which supersedes the probe's terminal
## classification on fused rows that have their unfused base in the
## table (22 Raaphorst-Moura-Stevens, 7 extended OA special, 1
## Cyclotomy, 30 in all); a fused row whose base is outside the table
## (8 Raaphorst-Moura-Stevens) keeps the probe's classification. The
## tail csv (arith_families_tail.R) covers the last 39 rows outside
## the paper-blocked families.
## Run from r/livingtable/ after the family scripts (paths adjusted for
## the repository layout; every csv is read from data/):
##   Rscript arith_tally.R | tee results/arith_tally_result.txt
cv <- read.csv("data/engine_coverage.csv", stringsAsFactors = FALSE)
u <- cv[cv$engine_class == "UNRESOLVED", ]
u$key <- paste(u$t, u$v, u$k, u$Source)
fam <- list(
    power  = { x <- read.csv("data/arith_formula_power.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$arith_tier, family = paste("Power", x$fam)) },
    dp     = { x <- read.csv("data/arith_formula_dp_table.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$arith_tier, family = "Direct product") },
    small  = { x <- read.csv("data/arith_formula_small.csv", stringsAsFactors = FALSE); x <- x[x$family != "Add n factors", ]; data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    addn   = { x <- read.csv("data/arith_formula_addn.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = ifelse(x$Source == "Add a factor", "Add a factor", "Add n factors")) },
    mc     = { x <- read.csv("data/arith_formula_mc.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    fuse   = { x <- read.csv("data/arith_formula_fuse.csv", stringsAsFactors = FALSE); x <- x[x$tier != "INGREDIENT_OUTSIDE_TABLE", ]; data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = "fuse") },
    cmtw   = { x <- read.csv("data/arith_formula_cmtw.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    mtvt   = { x <- read.csv("data/arith_formula_mtvt.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    tail   = { x <- read.csv("data/arith_families_tail.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    pcax   = { x <- read.csv("data/arith_formula_cmmssy.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    cz2    = { x <- read.csv("data/arith_formula_powercz.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = "Power CZ") },
    dcan   = { x <- read.csv("data/arith_formula_dcan.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = x$tier, family = x$family) },
    cz     = { x <- read.csv("data/arith_probe_powerCZ.csv", stringsAsFactors = FALSE); data.frame(key = paste(x$t, x$v, x$k, x$Source), tier = "OPEN", family = "Power CZ") },
    probe  = { x <- read.csv("data/arith_families_probe.csv", stringsAsFactors = FALSE); x <- x[x$family != "Add a factor", ]; data.frame(key = x$key, tier = x$tier, family = x$family) })
## the fuse family takes precedence over the probe's classification for a fused row whose
## unfused base is in the table, and only there
fam$probe <- fam$probe[!(fam$probe$key %in% fam$fuse$key), ]
## the paper-based passes take precedence: the Power CZ calibration over the earlier probe, and the DCAN pass
## over the strength-4 CMTW rows of arith_formula_cmtw.csv (strength 3 stays there)
fam$cz <- fam$cz[!(fam$cz$key %in% fam$cz2$key), ]
fam$cmtw <- fam$cmtw[!(fam$cmtw$key %in% fam$dcan$key), ]
all <- do.call(rbind, fam)
stopifnot(!any(duplicated(all$key)))
u$arith_tier <- all$tier[match(u$key, all$key)]
u$arith_family <- all$family[match(u$key, all$key)]
## every unresolved entry is covered by some family csv (the three paper passes closed the last
## families, so the earlier NOT_ATTEMPTED fallback is gone); a gap here is a missing csv
stopifnot(!any(is.na(u$arith_tier)))
classes <- c(RECURSIVE = "a construction reproduces the recorded size exactly from table ingredients, nothing built",
             RECURSIVE_TENTATIVE = "the same, but the reading may be coincidental or one ingredient is not a table quantity",
             RECURSIVE_STALE = "the construction now gives fewer rows than the entry, so the entry is stale",
             RECURSIVE_BELOW = "the record sits below the law (a better ingredient reading exists)",
             POST_OPTIMIZED = "a construction started the array and a post-optimization search finished it; the law gives the size before the search",
             DIRECT_ONLY = "a published one-off construction or search result with no table ingredient and no builder",
             OPEN = "attempted, construction not recovered (ingredients the tables do not publish)")
stopifnot(all(u$arith_tier %in% names(classes)))
cat("unresolved entries:", nrow(u), "\n\n== by class ==\n")
for (cl in names(classes)) cat(sprintf("  %-20s %5d  %s\n", cl, sum(u$arith_tier == cl), classes[cl]))
cat("\n== by family and class (families in alphabetical order, classes with a nonzero count) ==\n")
for (f in sort(unique(u$arith_family))) {
    tt <- table(u$arith_tier[u$arith_family == f]); tt <- tt[names(classes)[names(classes) %in% names(tt)]]
    cat(sprintf("  %-36s %s\n", f, paste(names(tt), tt, collapse = ", ")))
}
cat("\nsanity: classes sum to", sum(u$arith_tier %in% names(classes)), "of", nrow(u), "\n")
write.csv(u[, c("t","v","k","N","Source","arith_family","arith_tier")], "data/arith_tally.csv", row.names = FALSE)
cat("\nTALLY DONE\n")
