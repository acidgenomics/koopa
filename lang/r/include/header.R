options(
    ## "verbose" = TRUE,
    "error" = quote(quit(status = 1L)),
    "warning" = quote(quit(status = 1L))
)

includeDir <- normalizePath(dirname(sys.frame(1L)[["ofile"]]))
functionsDir <- file.path(dirname(includeDir), "functions")

files <- sort(list.files(
    path = functionsDir,
    pattern = "*.R",
    full.names = TRUE
))

invisible(lapply(X = files, FUN = source))

# Skip this check on Travis CI, which has an ancient version of R via apt.
if (!isTRUE(nzchar(Sys.getenv("TRAVIS")))) {
    stopifnot(packageVersion("base") >= "3.6")
}

if ("parallel" %in% rownames(installed.packages())) {
    options("mc.cores" = max(1L, parallel::detectCores() - 1L))
}

koopaHelp()
