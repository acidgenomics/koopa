#' Run shell command.
#' @note Updated 2020-02-28.
shell <- function(...) {
    status <- system2(...)
    stopifnot(status == 0L)
    invisible(status)
}
