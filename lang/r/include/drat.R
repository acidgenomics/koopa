#!/usr/bin/env Rscript

args <- commandArgs()
whichFile <- grep(pattern = "--file", x = args)
file <- args[whichFile]
file <- sub(pattern = "^--file=", replacement = "", x = file)
koopaPrefix <- normalizePath(file.path(dirname(file), "..", "..", ".."))
source(file.path(koopaPrefix, "lang", "r", "include", "header.R"))

local({
    wd <- getwd()
    if (hasPositionalArgs()) {
        pkgDir <- positionalArgs()[[1L]]
    } else {
        pkgDir <- "."
    }
    assert(
        isADir(pkgDir),
        isAFile(file.path(pkgDir, "DESCRIPTION"))
    )
    pkgDir <- realpath(pkgDir)
    pkgName <- basename(pkgDir)
    ## Handle `r-koopa` edge case.
    if (any(grepl("-", pkgName))) {
        pkgName <- strsplit(pkgName, "-")[[1L]][[2L]]
    }
    repoDir <- file.path("~", "monorepo", "drat")
    assert(isADir(repoDir))
    setwd(dirname(pkgDir))
    devtools::build(pkgDir)
    tarballs <- sort(list.files(
        path = ".",
        pattern = paste0(pkgName, "_.*.tar.gz"),
        recursive = FALSE
    ))
    file <- tail(tarballs, n = 1L)
    assert(isAFile(file))
    drat::insertPackage(
        file = file,
        repodir = repoDir,
        action = "archive"
    )
    invisible(file.remove(file))
    setwd(repoDir)
    shell(command = "git", args = c("checkout", "master"))
    shell(command = "git", args = c("add", "./"))
    shell(
        command = "git",
        ## FIXME NEED A FUNCTION FOR SHELL QUOTING HERE.
        args = c("commit", "-m", paste0("'Add ", basename(file), ".'"))
    )
    shell(command = "git", args = "push")
    setwd(wd)
    message(sprintf("Successfully added '%s'.", basename(file)))
    invisible(TRUE)
})
