## constant_rows_check.R - compares tools/constant_rows (the standalone C
## program the submission check uses) with cafast::maxconstant_c on every
## array in table/arrays. The two must agree on the number of rows that
## can be made constant. Run from the repository root:
##   cc -O2 -o tools/constant_rows tools/constant_rows.c
##   Rscript tools/constant_rows_check.R | tee results/constant_rows_check.txt
## Needs cafast (r/cafast) and caverify installed.
suppressMessages(library(cafast))
man <- read.csv("table/MANIFEST.csv", stringsAsFactors = FALSE)
bad <- 0; done <- 0
for (i in seq_len(nrow(man))) {
    f <- file.path("table/arrays", man$file[i]); v <- man$v[i]
    if (grepl("[.]gz$", f)) {   ## a stored compressed file: read.table reads gzip directly, the C program needs the text
        tf <- tempfile(fileext = ".txt"); writeLines(readLines(gzfile(f)), tf); f <- tf }
    D <- as.matrix(read.table(f, header = FALSE, na.strings = c("NA", "-", "*", "x", "X", "-1")))
    storage.mode(D) <- "integer"
    r <- maxconstant_c(D, verbose = 2)
    n_r <- length(attr(r, "constant_rows")$row_set_list)
    out <- system2("tools/constant_rows", c(shQuote(f), v), stdout = TRUE)
    n_c <- as.integer(sub("^constant_rows ([0-9]+) .*", "\\1", out[1]))
    ok <- identical(n_r, n_c)
    if (!ok) bad <- bad + 1
    done <- done + 1
    cat(sprintf("%-32s v=%2d  cafast %2d  constant_rows %2d  %s\n", man$file[i], v, n_r, n_c,
                if (ok) "ok" else "MISMATCH"))
}
cat(sprintf("%d arrays, %d mismatches\n", done, bad))
cat("CONSTANT ROWS CHECK:", if (bad == 0) "PASS" else "FAIL", "\n")
