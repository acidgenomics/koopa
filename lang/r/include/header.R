#!/usr/bin/env Rscript

local({
    ## Wrapping in a local call here, so functions don't persist downstream.

    #' Get help documentation, if necessary
    #'
    #' Display help if `--help` flag is defined.
    #'
    #' @note Updated 2022-04-11.
    #' @noRd
    getHelpIfNecessary <- function() {
        args <- commandArgs()
        if (!isTRUE(any(c("--help", "-h") %in% args))) return()
        koopaPrefix <- normalizePath(
            path = file.path(
                dirname(sys.frame(1L)[["ofile"]]),
                "..", "..", ".."
            ),
            mustWork = TRUE
        )
        file <- grep(pattern = "--file", x = args)
        file <- args[file]
        file <- sub(pattern = "^--file=", replacement = "", x = file)
        name <- basename(file)
        manFile <- file.path(koopaPrefix, "man", "man1", paste0(name, ".1"))
        if (!isTRUE(file.exists(manFile))) {
            stop(sprintf("No documentation for '%s'.", name), call. = FALSE)
        }
        system2(command = "man", args = manFile)
        quit()
    }

    #' Install R koopa package, if necessary
    #'
    #' @note Updated 2021-08-17.
    #' @noRd
    installIfNecessary <- function() {
        ## Minimum version of koopa R package.
        ## Ensure that this also gets updated in `koopa system variables`.
        minVersion <- "0.2.0"
        minVersion <- package_version(minVersion)
        stopifnot(requireNamespace("utils", quietly = TRUE))
        isInstalled <- function(pkgs) {
            basename(pkgs) %in% rownames(utils::installed.packages())
        }
        if (isTRUE(isInstalled("koopa"))) {
            if (isTRUE(utils::packageVersion("koopa") >= minVersion)) {
                return(invisible())
            }
        }
        if (isVanilla()) {
            stop("R packages should not be installed in '--vanilla' mode.")
        }
        message("Installing koopa R package.")
        if (isFALSE(isInstalled("BiocManager"))) {
            utils::install.packages("BiocManager")
        }
        ## FIXME Don't install koopa in the 'install r-packages' call.
        ## FIXME Simply install AcidDevTools instead.
        utils::install.packages(
            pkgs = "koopa",
            repos = c(
                "r.acidgenomics.com",
                BiocManager::repositories()
            ),
            dependencies = NA
        )
        stopifnot(packageVersion("koopa") >= minVersion)
        invisible(TRUE)
    }

    #' Is the current R session running in vanilla mode?
    #'
    #' @note Updated 2021-08-17.
    #' @noRd
    isVanilla <- function() {
        isTRUE("--vanilla" %in% commandArgs())
    }

    #' Should the current R session be running in verbose mode?
    #'
    #' @note Updated 2021-08-17.
    #' @noRd
    isVerbose <- function() {
        isTRUE("--verbose" %in% commandArgs())
    }

    #' R script header
    #'
    #' @note Updated 2022-03-02.
    #' @noRd
    header <- function() {
        options(
            "error" = quote(quit(status = 1L)),
            "warn" = 1L
            ## > "warning" = quote(quit(status = 1L))
        )
        if (isVerbose()) {
            options("verbose" = TRUE)
        }
        getHelpIfNecessary()
        installIfNecessary()
        invisible(TRUE)
    }

    header()
})
