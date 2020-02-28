#' Run shell command.
#' @note Updated 2020-02-28.
shell <- function(
    command,
    args,
    stdout = "",
    stderr = "",
    ...
) {
    out <- system2(
        command = command,
        args = args,
        stdout = stdout,
        stderr = stderr,
        ...
    )
    if (all(!isTRUE(stdout), !isTRUE(stderr))) {
        stopifnot(out == 0L)
    }
    invisible(out)
}
