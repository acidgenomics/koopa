## """
## Shared Rscript header.
## @note Updated 2020-08-09.
## """

stopifnot(packageVersion("base") >= "4.0")

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

## Create an invisible koopa environment.
.koopa <- new.env()

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

## Check that required R package dependencies are installed.
local({
    installGitHub <- .koopa[[".installGitHub"]]
    isPackageVersion <- .koopa[["isPackageVersion"]]
    ## GitHub dependencies.
    dependencies <- c(
        "acidgenomics/acidbase" = "0.1.12",
        "acidgenomics/acidgenerics" = "0.3.9",
        "acidgenomics/goalie" = "0.4.6",
        "acidgenomics/syntactic" = "0.4.2",
        "acidgenomics/bb8" = "0.2.20"
    )
    ## Update dependencies, if necessary.
    ok <- isPackageVersion(dependencies)
    repos <- names(dependencies)[!ok]
    if (length(repos) > 0L) {
        message(sprintf(
            "Updating koopa dependencies: %s",
            toString(basename(repos))
        ))
        stopifnot(requireNamespace("utils", quietly = TRUE))
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
                if (!isTRUE(pkg %in% rownames(utils::installed.packages()))) {
                    utils::install.packages(pkg)
                }
            }
        ))
        if (isTRUE(nzchar(Sys.getenv("GITHUB_PAT")))) {
            Sys.setenv("R_REMOTES_UPGRADE" = "always")
            remotes::install_github(repos)
        } else {
            installGitHub(repos, reinstall = TRUE)
        }
    }
    stopifnot(all(isPackageVersion(dependencies)))
    packages <- basename(names(dependencies))
    ## Attach package libraries:
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
    assign(x = "dependencies", value = dependencies, envir = .koopa)
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

attach(.koopa)
