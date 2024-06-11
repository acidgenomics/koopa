#!/usr/bin/env Rscript

options(
    "error" = quote(quit(status = 1L)),
    "warn" = 1L
)

main <- function() {
    stopifnot(requireNamespace("utils", quietly = TRUE))
    x <- utils::installed.packages(lib.loc = .Library)
    lgl <- x[, "Priority"] != "base"
    if (any(lgl)) {
        pkgs <- x[lgl, "Package", drop = TRUE]
        pkgs <- sort(unique(pkgs))
        cat(pkgs, sep = "\n")
    }
    invisible(TRUE)
}

main()
