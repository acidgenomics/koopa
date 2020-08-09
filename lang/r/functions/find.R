#' Find and move files in sequence
#' @note Updated 2020-08-09.
#' @noRd
findAndMoveInSequence <- function() {
    requireNamespaces("syntactic")
    posArgs <- positionalArgs()
    sourceDir <- realpath(posArgs[[1L]])
    targetDir <- realpath(posArgs[[2L]])
    assert(!identical(sourceDir, targetDir))
    sourceFiles <- sort(list.files(
        path = sourceDir,
        all.files = FALSE,
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = FALSE
    ))
    targetFiles <- file.path(
        targetDir,
        paste0(
            strtrim(
                syntactic::kebabCase(
                    paste(
                        autopadZeros(seq_along(sourceFiles)),
                        basenameSansExt(sourceFiles),
                        sep = "-"
                    ),
                    prefix = FALSE
                ),
                width = 100L
            ),
            ".", fileExt(sourceFiles)
        )
    )
    assert(identical(length(sourceFiles), length(targetFiles)))
    invisible(mapply(
        from = sourceFiles,
        to = targetFiles,
        FUN = function(from, to) {
            message(sprintf("Renaming '%s' to '%s'.", from, to))
            file.rename(from = from, to = to)
        }
    ))
    message(sprintf(
        "Successfully renamed %d files.",
        length(sourceFiles)
    ))
}
