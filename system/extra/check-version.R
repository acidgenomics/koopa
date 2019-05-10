#!/usr/bin/env Rscript

# Quit and return non-zero status code on error.
options(error = quote(quit(status = 1L)))

pos_args <- commandArgs(trailingOnly = TRUE)

program_name <- pos_args[[1L]]
stopifnot(is.character(program_name))

version <- package_version(pos_args[[2L]])
required_version <- package_version(pos_args[[3L]])

if (version < required_version) {
    stop(paste(program_name, version, "<", required_version), call. = FALSE)
}
