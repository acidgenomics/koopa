## """
## Shared Rscript header.
## @note Updated 2020-04-13.
## """

stopifnot(packageVersion("base") >= "3.6")

options(
    ## Exit on any errors.
    "error" = quote(quit(status = 1L)),
    ## Print out each command.
    ## > "verbose" = TRUE,
    ## Treat all warnings as errors.
    ## > "warn" = 2L,
    ## Exit on any warnings.
    "warning" = quote(quit(status = 1L))
)

## Create an invisible koopa environment.
.koopa <- new.env()



## Source shared function scripts  {{{1
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



## Check package dependencies  {{{1
## =============================================================================

## Check that required R package dependencies are installed.
local({
    installGitHub <- .koopa[["installGitHub"]]
    isPackageVersion <- .koopa[["isPackageVersion"]]
    dependencies <- c(
        "acidgenomics/acidbase" = "0.1.7",
        "acidgenomics/acidgenerics" = "0.3.4",
        "acidgenomics/goalie" = "0.4.4",
        "acidgenomics/syntactic" = "0.3.9",
        "acidgenomics/bb8" = "0.2.12"
    )
    if (!all(isPackageVersion(dependencies))) {
        message("Updating koopa dependencies.")
        stopifnot(requireNamespace("utils", quietly = TRUE))
        local({
            repos <- getOption("repos")
            repos[["CRAN"]] <- "https://cloud.r-project.org"
            options("repos" = repos)
        })
        ## Note that stringi is a dependency for syntactic.
        invisible(lapply(
            X = c("BiocManager", "remotes", "stringi"),
            FUN = function(pkg) {
                if (!isTRUE(pkg %in% rownames(utils::installed.packages()))) {
                    utils::install.packages(pkg)
                }
            }
        ))
        repos <- names(dependencies)
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



## Help mode  {{{1
## =============================================================================

.koopa[["koopaHelp"]]()



## Parallelization  {{{1
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
