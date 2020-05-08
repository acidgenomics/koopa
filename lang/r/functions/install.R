#' Install packages from GitHub
#'
#' This is a stripped down version of `bb8::installGitHub()`.
#'
#' @note Updated 2020-04-09.
#' @noRd
installGitHub <- function(
    repo,
    release = "latest",
    reinstall = FALSE
) {
    stopifnot(
        requireNamespace("utils", quietly = TRUE),
        all(grepl(x = repo, pattern = "^[^/]+/[^/]+$")),
        is.character(release) && identical(length(release), 1L),
        is.logical(reinstall) && identical(length(reinstall), 1L)
    )
    if (length(repo) > 1L && identical(release, "latest")) {
        release <- rep(release, times = length(repo))
    }
    stopifnot(identical(length(repo), length(release)))
    out <- mapply(
        repo = repo,
        release = release,
        MoreArgs = list(reinstall = reinstall),
        FUN = function(repo, release, reinstall) {
            ## > owner <- dirname(repo)
            pkg <- basename(repo)
            if (
                !isTRUE(reinstall) &&
                isTRUE(pkg %in% rownames(utils::installed.packages()))
            ) {
                message(sprintf("'%s' is already installed.", pkg))
                return(repo)
            }
            ## Get the tarball URL.
            if (identical(release, "latest")) {
                jsonUrl <- paste(
                    "https://api.github.com",
                    "repos",
                    repo,
                    "releases",
                    "latest",
                    sep = "/"
                )
                json <- withCallingHandlers(expr = {
                    tryCatch(expr = readLines(jsonUrl))
                }, warning = function(w) {
                    ## Ignore warning about missing final line in JSON return.
                    if (grepl(
                        pattern = "incomplete final line",
                        x = conditionMessage(w)
                    )) {
                        invokeRestart("muffleWarning")
                    }
                })
                ## Extract the tarball URL from the JSON output using base R.
                x <- unlist(strsplit(x = json, split = ",", fixed = TRUE))
                x <- grep(pattern = "tarball_url", x = x, value = TRUE)
                x <- strsplit(x = x, split = "\"", fixed = TRUE)[[1L]][[4L]]
                url <- x
            } else {
                url <- paste(
                    "https://github.com",
                    repo,
                    "archive",
                    paste0(release, ".tar.gz"),
                    sep = "/"
                )
            }
            tarfile <- tempfile(fileext = ".tar.gz")
            utils::download.file(
                url = url,
                destfile = tarfile,
                quiet = FALSE
            )
            ## Using a random string of 'A-Za-z' here for extracted directory.
            exdir <- file.path(
                tempdir(),
                paste0(
                    "untar-",
                    paste0(
                        sample(c(LETTERS, letters))[1L:6L],
                        collapse = ""
                    )
                )
            )
            utils::untar(
                tarfile = tarfile,
                exdir = exdir,
                verbose = TRUE
            )
            ## Locate the extracted package directory.
            pkgdir <- list.dirs(
                path = exdir,
                full.names = TRUE,
                recursive = FALSE
            )
            stopifnot(
                identical(length(pkgdir), 1L),
                isTRUE(dir.exists(pkgdir))
            )
            utils::install.packages(
                pkgs = pkgdir,
                repos = NULL,
                type = "source"
            )
            ## Clean up temporary files.
            file.remove(tarfile)
            unlink(exdir, recursive = TRUE)
        }
    )
    invisible(out)
}
