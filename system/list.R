#!/usr/bin/env Rscript

# List user-accessible programs exported in PATH.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)

# Note that this won't pick up in my current RStudio configuration.
koopa_dir <- Sys.getenv("KOOPA_DIR")
stopifnot(nzchar(koopa_dir))

printPrograms <- function(path) {
    path <- normalizePath(path, mustWork = TRUE)
    files <- list.files(
        path = path,
        all.files = FALSE,
        full.names = FALSE
    )
    cat(
        paste0(path, ":"),
        paste0("    ", files),
        sep = "\n"
    )
}

printPrograms(file.path(koopa_dir, "bin"))
