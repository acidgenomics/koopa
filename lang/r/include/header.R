## """
## Shared Rscript header.
## @note Updated 2020-08-11.
## """

.koopa <- new.env()
.koopa[["minVersion"]] <- package_version("0.0.1")
.koopa[["vanilla"]] <- isTRUE("--vanilla" %in% commandArgs())
.koopa[["verbose"]] <- isTRUE("--verbose" %in% commandArgs())

options(
    "error" = quote(quit(status = 1L)),
    "warn" = 2L,
    "warning" = quote(quit(status = 1L))
)
if (isTRUE(.koopa[["verbose"]])) {
    options("verbose" = TRUE)
}

stopifnot(packageVersion("base") >= "4.0")

local({
    .isInstalled <- function(pkgs) {
        basename(pkgs) %in% rownames(installed.packages())
    }
    if (isTRUE(.isInstalled("koopa"))) {
        ok <- packageVersion("koopa") >= .koopa[["minVersion"]]
    } else {
        ok <- FALSE
    }
    if (isTRUE(ok)) return()
    if (isTRUE(.koopa[["vanilla"]])) {
        stop("Outdated R packages cannot be updated in '--vanilla' mode.")
    }
    .install <- function(url) {
        install.packages(pkgs = url, repos = NULL)
    }
    message("Installing koopa R package.")
    .install("https://github.com/acidgenomics/koopa/archive/r.tar.gz")
    stopifnot(packageVersion("koopa") >= .koopa[["minVersion"]])
})

suppressPackageStartupMessages({
    library(koopa)
})
stopifnot(isCleanSystemLibrary())
koopaHelp()
attach(.koopa)
koopa <- .koopa[["koopa"]]
