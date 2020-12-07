#!/usr/bin/env Rscript

args <- commandArgs()
whichFile <- grep(pattern = "--file", x = args)
file <- args[whichFile]
file <- sub(pattern = "^--file=", replacement = "", x = file)
koopaPrefix <- normalizePath(file.path(dirname(file), "..", "..", ".."))
source(file.path(koopaPrefix, "lang", "r", "include", "header.R"))

## FIXME MOVE UP IF DRATTING IN CURRENT DIRECTORY.
## FIXME GET THE DIRECTORY NAME AUTOMATICALLY.
## FIXME DONT ERROR IF USER DOESNT PASS POSITIONAL ARGS.
## FIXME NEED TO DEFINE hasPositionalArgs

local({
    pkgDir <- positionalArgs()[[1L]]
    ## Handle `r-koopa` edge case.
    if (any(grepl("-", pkgDir))) {
        pkgName <- strsplit(pkgDir, "-")[[1L]][[2L]]
    } else {
        pkgName <- pkgDir
    }
    repoDir <- file.path("~", "monorepo", "drat")
    assert(
        dir.exists(pkgDir),
        dir.exists(repoDir)
    )
    print(pkgDir)
    return()  # FIXME
    devtools::build(pkgDir)
    tarballs <- sort(list.files(
        path = ".",
        pattern = paste0(pkgName, "_.*.tar.gz")
    ))
    file <- tail(tarballs, n = 1L)
    assert(file.exists(file))
    drat::insertPackage(
        file = file,
        repodir = repoDir,
        action = "prune"
    )
    # FIXME SWITCH TO REPO DIR AND COMMIT.
    invisible(file.remove(file))
})
