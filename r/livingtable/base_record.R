## base_record.R - the base record the propagation engine starts from: the
## baseline rows of table/ca_table.csv (tier CITED, source S1), as t, v, k, N
## and Source (the table's construction column), in table order. CITED rows
## from the literature (source S7, since 2026-10-25) are not part of it. Sourced by arith_engine.R and
## tests/check_chains.R, which need only base R.
##
## The engine's laws were calibrated on CAs::colbournBigFrame (snapshot
## colbourn-2024-11-ug), and the identity test reproduces its RECURSIVE
## entries. The baseline rows equal that record row for row (table/README.md),
## and BASE_FINGERPRINT is the md5 of a canonical text of those rows: one line
## per row, "t,v,k,N,Source", N written in full. A table whose baseline rows give
## any other fingerprint is refused: the caller stops and writes nothing.
## Changing a baseline row is then a recorded decision, with a new fingerprint
## and new references, never a silent change of the engine's starting point.
BASE_FINGERPRINT <- "3e568873d54f25ce100f2f01d232e129"
BASE_ROWS <- 13641

base_fingerprint <- function(t, v, k, N, Source) {
    f <- tempfile(); on.exit(unlink(f))
    con <- file(f, "wb")
    writeLines(sprintf("%d,%d,%d,%.0f,%s", as.integer(t), as.integer(v), as.integer(k), as.numeric(N), as.character(Source)),
               con, sep = "\n", useBytes = TRUE)
    close(con)
    unname(tools::md5sum(f))
}

## the table path: --table=PATH among the arguments, else the repository's own table
table_path <- function(args) {
    a <- grep("^--table=", args, value = TRUE)
    if (length(a)) sub("^--table=", "", a[length(a)]) else "../../table/ca_table.csv"
}

## returns list(ok, why, cb, fp); the caller decides how to stop
read_base <- function(path) {
    out <- list(ok = FALSE, why = "", cb = NULL, fp = NA_character_)
    if (!file.exists(path)) { out$why <- sprintf("the table %s was not found", path); return(out) }
    ## encoding = "UTF-8" marks the text without converting it, so the bytes read are the
    ## bytes in the file whatever the locale (fileEncoding would stop at a non-ASCII byte
    ## in a C locale)
    tab <- tryCatch(read.csv(path, stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8"),
                    error = function(e) NULL)
    need <- c("t", "v", "k", "N", "tier", "source_id", "construction")
    if (is.null(tab) || !all(need %in% names(tab))) { out$why <- sprintf("the table %s could not be read with columns %s", path, paste(need, collapse = ", ")); return(out) }
    ci <- tab[tab$tier %in% "CITED" & tab$source_id %in% "S1", ]
    num <- c(ci$t, ci$v, ci$k, ci$N)
    if (!nrow(ci) || any(is.na(num)) || !all(grepl("^[0-9]+$", num))) { out$why <- "a baseline row has a t, v, k or N that is not a whole number"; return(out) }
    cb <- data.frame(t = as.integer(ci$t), v = as.integer(ci$v), k = as.integer(ci$k), N = as.numeric(ci$N),
                     Source = ci$construction, stringsAsFactors = FALSE)
    out$fp <- base_fingerprint(cb$t, cb$v, cb$k, cb$N, cb$Source)
    if (nrow(cb) != BASE_ROWS || out$fp != BASE_FINGERPRINT) {
        out$why <- sprintf("the baseline rows of %s (%d rows, fingerprint %s) are not the record the engine was calibrated on (%d rows, fingerprint %s)",
                           path, nrow(cb), out$fp, BASE_ROWS, BASE_FINGERPRINT)
        return(out) }
    out$ok <- TRUE; out$cb <- cb
    out
}
