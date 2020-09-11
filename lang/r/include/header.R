## """
## Shared Rscript header.
## @note Updated 2020-09-11.
## """

options(
    "error" = quote(quit(status = 1L)),
    "warn" = 2L,
    "warning" = quote(quit(status = 1L))
)
if (isTRUE("--verbose" %in% commandArgs())) {
    options("verbose" = TRUE)
}
stopifnot(packageVersion("base") >= "4.0")

# Install koopa R package, if necessary.
local({
    koopaPrefix <- normalizePath(
        file.path(dirname(sys.frame(1L)[["ofile"]]), "..", "..", "..")
    )
    suppressMessages({
        source(file.path(koopaPrefix, "lang", "r", "include", "install.R"))
    })
})

## Load dependencies.
suppressPackageStartupMessages({
    library(koopa)
})

## Run additional header checks.
stopifnot(isCleanSystemLibrary())

## Display help if `--help` flag is defined.
local({
    args <- commandArgs()
    if (!isTRUE(any(c("--help", "-h") %in% args))) return()
    file <- grep(pattern = "--file", x = args)
    file <- args[file]
    file <- sub(pattern = "^--file=", replacement = "", x = file)
    name <- basename(file)
    manFile <- normalizePath(
        path = file.path(
            dirname(file), "..", "man", "man1", paste0(name, ".1")
        ),
        mustWork = FALSE
    )
    if (!isAFile(manFile)) {
        stop(sprintf("No documentation for '%s'.", name), call. = FALSE)
    }
    shell(command = "man", args = manFile)
    quit()
})
