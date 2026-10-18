## mac_rename_check.R - confirms the class names and counts by a run.
## Reruns arith_tally.R (which joins every family csv in data/ and
## rewrites data/arith_tally.csv) and arith_coverage_republish.R (which
## rewrites data/engine_coverage_v2.csv), then prints the class counts
## of both files against the expected numbers and the sum against
## 13,641. Run from r/livingtable/:
##   Rscript mac_rename_check.R | tee results/mac_rename_check_result.txt
## Nothing else is written. The two reruns also refresh
## results/arith_tally_result.txt and
## results/arith_coverage_republish_result.txt when run with tee as in
## README.md; this script captures their stdout and discards it.
invisible(capture.output(source("arith_tally.R", local = new.env())))
invisible(capture.output(source("arith_coverage_republish.R", local = new.env())))
expected <- c(VERIFIED = 987, VERIFIED_IMPROVED = 24, RECURSIVE = 4425, RECURSIVE_TENTATIVE = 531,
              RECURSIVE_STALE = 10, POST_OPTIMIZED = 380, SEARCH = 3623, DIRECT_ONLY = 339, OPEN = 3322)
ta <- read.csv("data/arith_tally.csv", stringsAsFactors = FALSE)
cv <- read.csv("data/engine_coverage_v2.csv", stringsAsFactors = FALSE)
cat("classes in data/arith_tally.csv (the 9,007 UNRESOLVED entries):\n"); print(table(ta$arith_tier))
cat("\nclasses in data/engine_coverage_v2.csv (all entries):\n")
ok <- TRUE
for (cl in names(expected)) { n <- sum(cv$tier == cl); flag <- if (n == expected[[cl]]) "ok" else "MISMATCH"; if (n != expected[[cl]]) ok <- FALSE
    cat(sprintf("  %-20s %5d  expected %5d  %s\n", cl, n, expected[[cl]], flag)) }
other <- setdiff(unique(cv$tier), names(expected))
if (length(other)) { ok <- FALSE; cat("  classes outside the nine:", paste(other, collapse = ", "), "\n") }
cat(sprintf("\nsum of the nine classes: %d of %d\n", sum(cv$tier %in% names(expected)), nrow(cv)))
cat("old names present in either file:", sum(grepl("^(RESOLVED|BETTER|LEAF|ARITHMETIC|ARITH_|TERMINAL_CLAIMED|NOT_ATTEMPTED)", c(ta$arith_tier, cv$tier, cv$engine_class))), "\n")
cat("terminal rows split: POST_OPTIMIZED with a postop tag", sum(ta$arith_tier == "POST_OPTIMIZED" & grepl("postop", ta$Source) & grepl("^terminal", ta$arith_family)),
    " DIRECT_ONLY without one", sum(ta$arith_tier == "DIRECT_ONLY" & !grepl("postop", ta$Source)), " (expected 361 and 339)\n")
cat("\nRENAME CHECK:", if (ok && sum(cv$tier %in% names(expected)) == nrow(cv) && nrow(cv) == 13641) "PASS" else "FAIL", "\n")
