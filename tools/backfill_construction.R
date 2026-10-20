## backfill_construction.R - fills the construction column of
## table/ca_table.csv for the verified rows that entered before the
## column existed (2026-10-20), from the catalogues in the CAs package
## that describe their sources. Nothing is guessed: each value names the
## catalogue entry it comes from. Writes table/construction_backfill.csv
## (array_sha256, source_detail, construction, basis); the Python step
## in tools/apply_construction_backfill.py writes the values into the
## table without touching any other byte. Run from the repository root:
##   Rscript tools/backfill_construction.R
suppressMessages(library(CAs))
tab <- read.csv("table/ca_table.csv", stringsAsFactors = FALSE)
todo <- tab$tier == "VERIFIED" & tab$source_id != "S7" & !nzchar(tab$construction)
cat("verified rows without a construction:", sum(todo), "\n")

dw <- get(data(DWYERcat, envir = environment()))
tj <- get(data(TJcat, envir = environment()))
tjname <- tj$nameInTJ2level_CAs
out <- NULL
for (i in which(todo)) {
    sd <- tab$source_detail[i]; cons <- ""; basis <- ""
    if (grepl("^aadwyer/CA_Database ", sd)) {
        f <- sub("^aadwyer/CA_Database (Repository/CA/)?([^ ]+) via.*", "\\2", sd)
        j <- match(f, rownames(dw))
        if (!is.na(j)) {
            cons <- paste0("Dwyer CA_Database source code \"", trimws(dw$Source[j]),
                           "\" (Aaron Dwyer's abbreviation for the method; many of his arrays ",
                           "cite personal communication with Colbourn)")
            basis <- paste0("CAs::DWYERcat[\"", f, "\", \"Source\"]")
        }
    } else if (grepl("^math.nist.gov/coveringarrays ipof", sd)) {
        cons <- "IPOG-F (NIST covering array library)"
        basis <- "NIST library, ipof directory"
    } else if (grepl("^CAs data TJ2level_CAs ", sd)) {
        nm <- sub("^CAs data TJ2level_CAs ([^,]+),.*", "\\1", sd)
        j <- match(nm, tjname)
        if (!is.na(j)) {
            cons <- "Torres-Jimenez binary array from his site (CAs data TJ2level_CAs); method not recorded per array"
            if (nzchar(tj$replaceable[j]))
                cons <- paste0("Torres-Jimenez binary array from his site (CAs data TJ2level_CAs); ",
                               "reproducible in CAs by ", tj$code[j])
            basis <- paste0("CAs::TJcat[\"", rownames(tj)[j], "\", ]")
        }
    } else if (grepl("^CAs data CAEX_CAs ", sd)) {
        nm <- sub("^CAs data CAEX_CAs ([^,]+),.*", "\\1", sd)
        if (nm %in% names(CAEX_CAs)) {
            cons <- paste0("Torres-Jimenez et al. (2021): strength 2, 3 levels, product construction ",
                           "and column extension by computer search; stored array ", nm,
                           " of CAs CAEX_CAs, lineage in CAs CAEX_lineages")
            basis <- paste0("CAs::CAEX_CAs[[\"", nm, "\"]]")
        }
    } else if (grepl("^CAs::KSK\\(", sd)) {
        cons <- paste0("KSK construction (Kleitman-Spencer, Katona), strength 2, 2 levels, ",
                       sub(", CAs.*$", "", sd))
        basis <- "the source_detail is the construction call"
    }
    out <- rbind(out, data.frame(array_sha256 = tab$array_sha256[i], source_detail = sd,
                                 construction = cons, basis = basis, stringsAsFactors = FALSE))
}
cat("filled:", sum(nzchar(out$construction)), " left empty:", sum(!nzchar(out$construction)), "\n")
print(table(sub(" .*", "", out$source_detail), nzchar(out$construction)))
write.csv(out, "table/construction_backfill.csv", row.names = FALSE)
