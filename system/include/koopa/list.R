#!/usr/bin/env -S Rscript --vanilla
## shebang requires env from coreutils >= 8.30.

## List user-accessible programs exported in PATH.
## Updated 2019-07-30.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)

message("koopa programs exported in PATH")

## Note that these won't pick up in my current RStudio configuration.
koopa_dir <- Sys.getenv("KOOPA_HOME")
path <- Sys.getenv("PATH")
stopifnot(
    nzchar(koopa_dir),
    grepl("koopa", path)
)

printPrograms <- function(path) {
    path <- normalizePath(path, mustWork = TRUE)
    files <- list.files(
        path = path,
        all.files = FALSE,
        full.names = TRUE
    )
    files <- files[!file.info(files)$isdir]
    if (length(files) == 0L) {
        return()
    }
    cat(
        "",
        paste0(path, ":"),
        "",
        paste0("    ", basename(files)),
        sep = "\n"
    )
}

## Split PATH string into a character vector.
path <- strsplit(x = path, split = ":", fixed = TRUE)[[1L]]
keep <- grepl("koopa", path)
path <- path[keep]

invisible(lapply(X = path, FUN = printPrograms))
