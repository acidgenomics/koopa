#!/usr/bin/env Rscript

local({
    minVersion <- package_version("0.0.1")
    isInstalled <- function(pkgs) {
        basename(pkgs) %in% rownames(installed.packages())
    }
    if (isTRUE(isInstalled("koopa"))) {
        ok <- packageVersion("koopa") >= minVersion
    } else {
        ok <- FALSE
    }
    if (isTRUE(ok)) {
        message("koopa R package is already installed.")
        return(invisible())
    }
    if (isTRUE("--vanilla" %in% commandArgs())) {
        stop(paste(
            "R packages cannot be updated in '--vanilla' mode.",
            "Try running 'install-r-packages' or 'update-r-packages'.",
            sep = "\n"
        ), call. = FALSE)
    }
    installURL <- function(url) {
        install.packages(pkgs = url, repos = NULL)
    }
    message("Installing koopa R package.")
    installURL("https://github.com/acidgenomics/koopa/archive/r.tar.gz")
    stopifnot(packageVersion("koopa") >= minVersion)
})
