#!/usr/bin/env Rscript

# List user-accessible programs exported in PATH.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)

message("koopa programs exported in PATH")

# Note that these won't pick up in my current RStudio configuration.
koopa_dir <- Sys.getenv("KOOPA_DIR")
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
        full.names = FALSE
    )
    cat(
        "",
        paste0(path, ":"),
        paste0("    ", files),
        sep = "\n"
    )
}

# Split PATH string into a character vector.
path <- strsplit(x = path, split = ":", fixed = TRUE)[[1L]]
keep <- grepl(file.path("koopa", "bin"), path)
path <- path[keep]

invisible(lapply(X = path, FUN = printPrograms))
