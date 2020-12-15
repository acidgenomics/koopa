#!/usr/bin/env Rscript

args <- commandArgs()
whichFile <- grep(pattern = "--file", x = args)
file <- args[whichFile]
file <- sub(pattern = "^--file=", replacement = "", x = file)
koopaPrefix <- normalizePath(file.path(dirname(file), "..", "..", ".."))
source(file.path(koopaPrefix, "lang", "r", "include", "header.R"))

# required:
# - organism
# - genomeBuild

# optional:
# - release
# - type
# - annotation
# - output-dir

# flag
# - decompress

# required
# optional
# flags
# positional

local({
    # FIXME THIS IS ERRORING WHEN ARGUMENT CONTAINS SPACES.
    input <- parseArgs(
        required = c(
            "organism"
            #"organism",
            #"genome-build"
        ),
        optional = c(
            "release",
            "type",
            "annotation",
            "output-dir"
        ),
        flags = "decompress",
        positional = FALSE
    )
    return(input)

    args <- list()
    args[["organism"]] <- input[["organism"]]
    args[["genomeBuild"]] <- input[["genome-build"]]
    if (isSubset("release", names(input[["release"]]))) {
        args[["release"]] <- input[["release"]]
    }
    if (isSubset("type", names(input[["type"]]))) {
        args[["type"]] <- input[["type"]]
    }
    if (isSubset("annotation", names(input[["annotation"]]))) {
        args[["annotation"]] <- input[["annotation"]]
    }
    ## FIXME Does this sanitize to camelCase?
    if (isSubset("output-dir", names(input[["annotation"]]))) {
        args[["outputDir"]] <- input[["output-dir"]]
    }
    if (isSubset("decompress", names(input[["flags"]]))) {
        args[["decompress"]] <- TRUE
    }
    library(AcidGenomes)
    do.call(
        what = AcidGenomes::downloadEnsemblGenome,
        args = args
    )
})
