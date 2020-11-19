#!/usr/bin/env Rscript

args <- commandArgs()
whichFile <- grep(pattern = "--file", x = args)
file <- args[whichFile]
file <- sub(pattern = "^--file=", replacement = "", x = file)
koopaPrefix <- normalizePath(file.path(dirname(file), "..", "..", ".."))
source(file.path(koopaPrefix, "lang", "r", "include", "header.R"))

local({
    parse <- parseArgs(
        optional = c("days", "dir"),
        flags = "force",
        positional = TRUE
    )
    args <- list(
        images = parse[["positional"]],
        force = "force" %in% parse[["flags"]]
    )
    optional <- parse[["optional"]]
    if (!is.null(optional)) {
        if (isSubset("days", names(optional))) {
            args[["days"]] <- as.numeric(optional[["days"]])
        }
        if (isSubset("dir", names(optional))) {
            args[["dir"]] <- optional[["dir"]]
        }
    }
    do.call(what = dockerBuildAllTags, args = args)
})
