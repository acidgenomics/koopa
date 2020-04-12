#!/usr/bin/env Rscript

## Check that all scripts in `bin` and `sbin` directories have corresponding
## documentation in `man/man1`.

options(
    "error" = quote(quit(status = 1L)),
    "warning" = quote(quit(status = 1L))
)

args <- commandArgs(trailingOnly = FALSE)
whichFile <- grep(pattern = "--file", x = args)
file <- args[whichFile]
file <- sub(pattern = "^--file=", replacement = "", x = file)
koopaPrefix <- normalizePath(file.path(dirname(file), "..", ".."))

stopifnot(requireNamespace("utils", quietly = TRUE))

## Locate the relevant bin directories.
bins <- sort(list.files(
    path = koopaPrefix,
    pattern = "^[s]?bin$",
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = TRUE
))
bins <- bins[!grepl(
    pattern = file.path(koopaPrefix, "(opt|system)", ""),
    x = bins
)]

## List the files for each bin directory.
scripts <- sort(unlist(lapply(
    X = bins,
    FUN = list.files,
    full.names = TRUE,
    recursive = FALSE,
    include.dirs = FALSE
)))

## Map to corresponding man files.
manpages <- gsub(
    pattern = file.path("", "[s]?bin", ""),
    replacement = file.path("", "man", "man1", ""),
    x = scripts
)
stopifnot(!any(duplicated(manpages)))
manpages <- paste0(manpages, ".1")
ok <- file.exists(manpages)
if (!all(ok)) {
    stop(paste(
        c(
            "Missing man pages:",
            utils::capture.output(
                cat(manpages[!ok], sep = "\n")
            )
        ),
        collapse = "\n"
    ))
}

## Check for orphan man pages referring to deleted scripts.
