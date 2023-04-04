#!/usr/bin/env Rscript

options(
    "error" = quote(quit(status = 1L)),
    "warn" = 1L
)

main <- function() {
    pkgs <- commandArgs(trailingOnly = TRUE)
    stopifnot(
        requireNamespace("utils", quietly = TRUE),
        length(pkgs) > 0L
    )
    utils::remove.packages(pkgs = pkgs, lib = .Library)
    invisible(TRUE)
}

main()
