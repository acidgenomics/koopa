#!/usr/bin/env Rscript

## """
## Check that all scripts in `bin` and `sbin` directories have corresponding
## documentation in `man/man1`.
## """

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

## Exclude these directories from search.
exclude <- file.path(koopaPrefix, "(dotfiles|opt|system)", "")



## Bin-to-man mapping  {{{1
## =============================================================================

bins <- sort(list.files(
    path = koopaPrefix,
    pattern = "^[s]?bin$",
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = TRUE
))
bins <- bins[!grepl(pattern = exclude, x = bins)]

message(sprintf(
    fmt = "Detected %d 'bin/sbin' directories.",
    length(bins)
))

## Scripts  {{{2
## -----------------------------------------------------------------------------

## List the files for each bin directory.
scripts <- sort(unlist(lapply(
    X = bins,
    FUN = list.files,
    full.names = TRUE,
    recursive = FALSE,
    include.dirs = FALSE
)))

message(sprintf(
    fmt = "Detected %d scripts.",
    length(scripts)
))

## Man files  {{{2
## -----------------------------------------------------------------------------

message("Checking that all scripts have corresponding man files.")

## Map to corresponding man files.
manfiles <- gsub(
    pattern = file.path("", "[s]?bin", ""),
    replacement = file.path("", "man", "man1", ""),
    x = scripts
)
stopifnot(!any(duplicated(manfiles)))
manfiles <- paste0(manfiles, ".1")
ok <- file.exists(manfiles)
if (!all(ok)) {
    stop(paste(
        c(
            "Missing man pages detected. Resolve with:",
            utils::capture.output(
                cat(
                    paste("touch", manfiles[!ok]),
                    sep = "\n"
                )
            )
        ),
        collapse = "\n"
    ))
}



## Orphaned man-to-bin files  {{{1
## =============================================================================

message("Checking for orphaned man files.")

mans <- sort(list.files(
    path = koopaPrefix,
    pattern = "^man1$",
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = TRUE
))
mans <- mans[!grepl(pattern = exclude, x = mans)]

message(sprintf(
    fmt = "Detected %d 'man1' directories.",
    length(mans)
))

manfiles2 <- sort(unlist(lapply(
    X = mans,
    FUN = list.files,
    full.names = TRUE,
    recursive = FALSE,
    include.dirs = FALSE
)))

orphans <- setdiff(manfiles2, manfiles)
if (length(orphans) > 0L) {
    stop(paste(
        c(
            "Orphaned man pages detected. Resolve with:",
            utils::capture.output(
                cat(
                    paste("rm", orphans),
                    sep = "\n"
                )
            )
        ),
        collapse = "\n"
    ))
}
