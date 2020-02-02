#!/usr/bin/env Rscript

# Skip this check on Travis CI, which has an ancient version of R.
if (!isTRUE(nzchar(Sys.getenv("TRAVIS")))) {
    stopifnot(packageVersion("base") >= "3.6")
}

options(
    "error" = quote(quit(status = 1L)),
    "warning" = quote(quit(status = 1L))
)

#' Help
#'
#' Display help via `man` when `--help` or `-h` flag is detected.
#'
#' @note Updated 2020-02-01.
#' @noRd
koopaHelp <- function() {
    args <- commandArgs(trailingOnly = FALSE)
    if (!isTRUE(any(c("--help", "-h") %in% args))) {
        return(invisible())
    }
    file <- grep(pattern = "--file", x = args)
    file <- args[file]
    file <- sub(pattern = "^--file=", replacement = "", x = file)
    name <- basename(file)
    system2(command = "man", args = name)
    quit()
}

koopaHelp()
