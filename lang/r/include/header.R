#!/usr/bin/env Rscript

## Wrapping in a local call here, so functions don't persist downstream.
local({
    #' Check if r-koopa package is installed, and meets dependency requirements.
    #'
    #' @note Updated 2023-10-16.
    #' @noRd
    checkInstall <- function() {
        ## Minimum version of koopa R package.
        minVersion <- package_version("0.5.1")
        stopifnot(requireNamespace("utils", quietly = TRUE))
        isInstalled <- function(pkgs) {
            basename(pkgs) %in% rownames(utils::installed.packages())
        }
        if (isFALSE(isInstalled("koopa"))) {
            stop(
                 sprintf(
                    "%s is not installed. Run '%s' to resolve.",
                    "koopa R package", "koopa reinstall r"
                ),
                 call. = FALSE
            )
        }
        if (isFALSE(utils::packageVersion("koopa") >= minVersion)) {
            stop(
                sprintf(
                    "%s %s %s is required. Run '%s' to resolve.",
                    "koopa R package", ">=", as.character(minVersion),
                    "koopa reinstall r"
                ),
                call. = FALSE
            )
        }
        invisible(TRUE)
    }

    #' Get help documentation, if necessary
    #'
    #' Display help if `--help` flag is defined.
    #'
    #' @note Updated 2022-05-23.
    #' @noRd
    getHelpIfNecessary <- function() {
        args <- commandArgs()
        if (!isTRUE(any(c("--help", "-h") %in% args))) {
            return()
        }
        koopaPrefix <- normalizePath(
            path = file.path(
                dirname(thisFile()),
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
            stop(
                sprintf("No documentation for '%s'.", name),
                call. = FALSE
            )
        }
        system2(command = "man", args = manFile)
        quit()
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

    #' Get the absolute path of this file
    #'
    #' @note Updated 2022-05-23.
    #' @noRd
    thisFile <- function() {
        sys.frame(1L)[["ofile"]]
    }

    #' Main R script header
    #'
    #' @note Updated 2022-03-02.
    #' @noRd
    main <- function() {
        options(
            "error" = quote(quit(status = 1L)),
            "warn" = 1L
            ## > "warning" = quote(quit(status = 1L))
        )
        if (isVerbose()) {
            options("verbose" = TRUE)
        }
        getHelpIfNecessary()
        checkInstall()
        invisible(TRUE)
    }

    main()
})
