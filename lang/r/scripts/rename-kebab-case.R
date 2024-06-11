#!/usr/bin/env Rscript

options(
    "error" = quote(quit(status = 1L)),
    "warn" = 1L
)

path <- normalizePath(
    path = sub(
        pattern = "^--file=",
        replacement = "",
        x = grep(
            pattern = "^--file=",
            x = commandArgs(),
            value = TRUE
        )
    ),
    mustWork = TRUE
)
source(file.path(dirname(dirname(path)), "functions.R"))

main <- function() {
    syntacticRename(fun = "kebabCase")
}

main()
