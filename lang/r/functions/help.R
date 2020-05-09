#' Help
#'
#' Display help via `man` when `--help` or `-h` flag is detected.
#'
#' @note Updated 2020-04-12.
#' @noRd
#'
#' @return System command when `--help` is set, or invisible `NULL`.
koopaHelp <- function() {
    stopifnot(requireNamespace("acidbase", quietly = TRUE))
    args <- commandArgs()
    if (!isTRUE(any(c("--help", "-h") %in% args))) {
        return(invisible())
    }
    file <- grep(pattern = "--file", x = args)
    file <- args[file]
    file <- sub(pattern = "^--file=", replacement = "", x = file)
    name <- basename(file)
    acidbase::shell(command = "man", args = name)
    quit()
}
