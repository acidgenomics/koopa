## """
## Shared Rscript header.
## @note Updated 2020-08-11.
## """

options(
    ## Exit on any errors.
    "error" = quote(quit(status = 1L)),
    ## Print out each command.
    ## > "verbose" = TRUE,
    ## Treat all warnings as errors.
    "warn" = 2L,
    ## Exit on any warnings.
    "warning" = quote(quit(status = 1L))
)

stopifnot(packageVersion("base") >= "4.0")

.koopa <- new.env()
.koopa[["vanilla"]] <-
    isTRUE("--vanilla" %in% commandArgs())
.koopa[["dependencies"]] <-
    c(
        "acidgenomics/acidbase" = "0.1.12",
        "acidgenomics/acidgenerics" = "0.3.9",
        "acidgenomics/goalie" = "0.4.6",
        "acidgenomics/syntactic" = "0.4.2",
        "acidgenomics/bb8" = "0.2.23"
    )

## Source shared function scripts {{{1
## =============================================================================

local({
    includeDir <- normalizePath(dirname(sys.frame(1L)[["ofile"]]))
    prefix <- normalizePath(file.path(includeDir, "..", "..", ".."))
    assign(x = "prefix", value = prefix, envir = .koopa)
    koopa <- file.path(prefix, "bin", "koopa")
    stopifnot(isTRUE(file.exists(koopa)))
    assign(x = "koopa", value = koopa, envir = .koopa)
    functionsDir <- file.path(dirname(includeDir), "functions")
    scripts <- sort(list.files(
        path = functionsDir,
        pattern = "*.R",
        full.names = TRUE
    ))
    ## Assign the functions into `.koopa` environment.
    invisible(lapply(X = scripts, FUN = source, local = .koopa))
    assign(x = "scripts", value = scripts, envir = .koopa)
})

## Here's how to source functions into active environment.
## > invisible(lapply(X = .koopa[["scripts"]], FUN = source, local = FALSE))

## Check package dependencies {{{1
## =============================================================================

local({
    vanilla <- .koopa[["vanilla"]]
    dependencies <- .koopa[["dependencies"]]
    installGitHub <- .koopa[[".installGitHub"]]
    isInstalled <- function(pkgs) {
        basename(pkgs) %in% rownames(installed.packages())
    }
    isPackageVersion <- .koopa[["isPackageVersion"]]
    ok <- isPackageVersion(dependencies)
    repos <- names(dependencies)[!ok]
    if (length(repos) > 0L) {
        if (isTRUE(vanilla)) {
            stop(paste0(
                "koopa dependencies are outdated and ",
                "cannot be updated in '--vanilla' mode."
            ))
        }
        message(sprintf(
            "Updating koopa dependencies: %s",
            toString(basename(repos))
        ))
        local({
            repos <- getOption("repos")
            repos[["CRAN"]] <- "https://cloud.r-project.org"
            options("repos" = repos)
        })
        ## Note that stringi is a dependency for syntactic.
        invisible(lapply(
            X = c(
                "BiocManager",
                "cli",
                "crayon",
                "remotes",
                "stringi",
                "stringr"
            ),
            FUN = function(pkg) {
                if (!isTRUE(isInstalled(pkg))) {
                    install.packages(pkg)
                }
            }
        ))
        if (isTRUE(nzchar(Sys.getenv("GITHUB_PAT")))) {
            remotes::install_github(repos, upgrade = "never")
        } else {
            installGitHub(repos, reinstall = TRUE)
        }
    }
    ok <- isPackageVersion(dependencies)
    if (!all(ok)) {
        stop(sprintf(
            "Dependency check failure:\n%s",
            paste(capture.output(print(ok)), collapse = "\n")
        ))
    }
    ## Attach package libraries:
    ## > packages <- basename(names(dependencies))
    ## > invisible(lapply(
    ## >     X = packages,
    ## >     FUN = library,
    ## >     character.only = TRUE
    ## > ))
    ## Or simply require namespace:
    ## > invisible(lapply(
    ## >     X = packages,
    ## >     FUN = requireNamespace,
    ## >     quietly = TRUE
    ## > ))
})

## Help mode {{{1
## =============================================================================

.koopa[["koopaHelp"]]()

## Parallelization {{{1
## =============================================================================

## Set number of cores for parallelization, if necessary.
## Necessary when running in `Rscript --vanilla` mode.
## Otherwise this will be handled automatically by `Rprofile.site` file.
if (
    !isTRUE(nzchar(getOption("mc.cores"))) &&
    isTRUE(requireNamespace("parallel", quietly = TRUE))
) {
    options("mc.cores" = parallel::detectCores())
}

## Dependencies {{{1
## =============================================================================

suppressPackageStartupMessages({
    library(acidbase)
    library(goalie)
})
stopifnot(bb8::isCleanSystemLibrary())
attach(.koopa)
koopa <- .koopa[["koopa"]]
