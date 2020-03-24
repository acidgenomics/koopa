## """
## Shared Rscript header.
## @note Updated 2020-03-24.
## """

options(
    ## "verbose" = TRUE,
    ## "warn" = 2L,
    "error" = quote(quit(status = 1L)),
    "warning" = quote(quit(status = 1L))
)

.includeDir <- normalizePath(dirname(sys.frame(1L)[["ofile"]]))
.functionsDir <- file.path(dirname(.includeDir), "functions")

.files <- sort(list.files(
    path = .functionsDir,
    pattern = "*.R",
    full.names = TRUE
))

invisible(lapply(X = .files, FUN = source))

# Skip this check on Travis CI, which has an ancient version of R via apt.
if (!isTRUE(nzchar(Sys.getenv("TRAVIS")))) {
    stopifnot(packageVersion("base") >= "3.6")
}

# Set number of cores for parallelization, if necessary.
if (
    !isTRUE(nzchar(getOption("mc.cores"))) &&
    isTRUE("parallel" %in% rownames(installed.packages()))
) {
    options("mc.cores" = parallel::detectCores())
}

koopaHelp()

koopaPrefix <- normalizePath(file.path(.includeDir, "..", "..", ".."))
koopa <- file.path(koopaPrefix, "bin", "koopa")
stopifnot(file.exists(koopa))

.variablesFile <- file.path(
    koopaPrefix,
    "system",
    "include",
    "variables.txt"
)
