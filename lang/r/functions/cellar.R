#' Prune the cellar
#' @note Updated 2020-08-09.
#' @noRd
pruneCellar <- function() {
    prefix <- shell(
        command = koopa,
        args = "cellar-prefix",
        stdout = TRUE
    )
    apps <- sort(list.dirs(
        path = prefix,
        full.names = TRUE,
        recursive = FALSE
    ))
    versions <- lapply(
        X = apps,
        FUN = function(app) {
            x <- list.dirs(
                path = app,
                full.names = FALSE,
                recursive = FALSE
            )
            if (all(grepl(pattern = "^[.0-9]+$", x = x))) {
                x <- numeric_version(x)
            }
            x <- sort(x)
            x
        }
    )
    names(versions) <- basename(apps)
    latest <- lapply(X = versions, FUN = tail, n = 1L)
    prune <- mapply(
        FUN = setdiff,
        x = versions,
        y = latest,
        SIMPLIFY = FALSE,
        USE.NAMES = TRUE
    )
    prune <- Filter(f = hasLength, x = prune)
    prunePaths <- sort(unlist(mapply(
        app = names(prune),
        versions = prune,
        MoreArgs = list(prefix = prefix),
        FUN = function(app, versions, prefix) {
            file.path(prefix, app, versions)
        },
        SIMPLIFY = FALSE,
        USE.NAMES = FALSE
    )))
    unlink(prunePaths, recursive = TRUE)
    shell(
        command = file.path(
            koopaPrefix,
            "os",
            "linux",
            "bin",
            "remove-broken-cellar-symlinks"
        ),
        args = ""
    )
}

#' Unlink cellar files
#' @note Updated 2020-08-09.
#' @noRd
unlinkCellar <- function() {
    posArgs <- positionalArgs()
    app <- posArgs[[1L]]
    cellarPrefix <- shell(
        command = koopa,
        args = "cellar-prefix",
        stdout = TRUE
    )
    makePrefix <- shell(
        command = koopa,
        args = "make-prefix",
        stdout = TRUE
    )
    ## List all files in make prefix (e.g. '/usr/local').
    files <- list.files(
        path = makePrefix,
        all.files = TRUE,
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = FALSE,
        no.. = TRUE
    )
    ## This step can be CPU intensive and safe to skip.
    files <- sort(files)
    ## Resolve the file paths, to match cellar symlinks.
    realpaths <- realpath(files)
    ## Get the symlinks that resolve to the desired app.
    hits <- grepl(pattern = file.path(cellarPrefix, app), x = realpaths)
    message(sprintf("%d cellar symlinks detected.", sum(hits)))
    ## Ready to remove the maching symlinks.
    trash <- files[hits]
    file.remove(trash)
}
