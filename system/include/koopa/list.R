#!/usr/bin/env Rscript

## List user-accessible programs exported in PATH.
## Updated 2019-11-26.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)

message("koopa programs exported in PATH.")

## Note that these won't pick up in isolated RStudio configuration.
## > Sys.setenv("KOOPA_PREFIX" = "/usr/local/koopa")
koopaHome <- Sys.getenv("KOOPA_PREFIX")
path <- Sys.getenv("PATH")
stopifnot(
    nzchar(koopaHome),
    any(grepl("koopa", path))
)

printPrograms <- function(path) {
    if (!dir.exists(path)) return(invisible())
    path <- normalizePath(path, mustWork = TRUE)
    files <- list.files(
        path = path,
        all.files = FALSE,
        full.names = TRUE
    )
    keep <- !file.info(files)[["isdir"]]
    files <- files[keep]
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
