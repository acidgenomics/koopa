#' Unlink cellar files
#' @note Updated 2020-08-09.
#' @noRd
unlinkCellar <- function() {
    koopa <- .koopa[["koopa"]]
    args <- parseArgs(positionalArgs = TRUE)
    posArgs <- args[["positionalArgs"]]
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
