#!/usr/bin/env Rscript

local({
    minVersion <- package_version("0.0.7")
    isInstalled <- function(pkgs) {
        basename(pkgs) %in% rownames(installed.packages())
    }
    if (isTRUE(isInstalled("koopa"))) {
        ok <- packageVersion("koopa") >= minVersion
    } else {
        ok <- FALSE
    }
    if (isTRUE(ok)) {
        message(sprintf(
            "koopa R package %s is already installed.",
            packageVersion("koopa")
        ))
        return(invisible())
    }
    if (isTRUE("--vanilla" %in% commandArgs())) {
        stop(paste(
            "R packages cannot be installed in '--vanilla' mode.",
            "Run 'koopa install r' to resolve.",
            sep = "\n"
        ), call. = FALSE)
    }
    message("Installing koopa R package.")
    install.packages(
        pkgs = "koopa",
        repos = c("r.acidgenomics.com", getOption("repos"))
    )
    stopifnot(packageVersion("koopa") >= minVersion)
})
