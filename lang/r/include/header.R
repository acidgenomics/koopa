## """
## Shared Rscript header.
## @note Updated 2020-08-11.
## """

## FIXME Need a special case for r-koopa install procedure.

.koopa <- new.env()
.koopa[["vanilla"]] <- isTRUE("--vanilla" %in% commandArgs())
.koopa[["verbose"]] <- isTRUE("--verbose" %in% commandArgs())

options(
    "error" = quote(quit(status = 1L)),
    "warn" = 2L,
    "warning" = quote(quit(status = 1L))
)
if (isTRUE(.koopa[["verbose"]])) {
    options("verbose" = TRUE)
}

stopifnot(packageVersion("base") >= "4.0")

## Check package dependencies {{{1
## =============================================================================

.koopa[["dependencies"]] <-
    c(
        "acidgenomics/acidbase" = "0.1.12",
        "acidgenomics/acidgenerics" = "0.3.9",
        "acidgenomics/goalie" = "0.4.6",
        "acidgenomics/syntactic" = "0.4.2",
        "acidgenomics/bb8" = "0.2.23"
    )

## FIXME Need to rework this using new koopa R package.

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
})

.koopa[["koopaHelp"]]()

suppressPackageStartupMessages({
    library(koopa)
})
assert(isCleanSystemLibrary())
attach(.koopa)
koopa <- .koopa[["koopa"]]
