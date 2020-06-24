#' Header 1
#' @note Updated 2020-06-24.
#' @noRd
h1 <- function(x) {
    if (isTRUE(hasCli())) {
        stopifnot(requireNamespace("cli", quietly = TRUE))
        cli::cli_h1(x)
    } else {
        message(paste0("\n", x, "\n"))
    }
    invisible(x)
}



#' Header 2
#' @note Updated 2020-06-24.
#' @noRd
h2 <- function(x) {
    if (isTRUE(hasCli())) {
        stopifnot(requireNamespace("cli", quietly = TRUE))
        cli::cat_line()
        cli::cli_h2(x)
    } else {
        message(paste0("\n", x, ":"))
    }
    invisible(x)
}



#' Return status labels, with optional color support
#' @note Updated 2020-04-09.
#' @noRd
status <- function() {
    x <- list(
        fail = "FAIL",
        note = "NOTE",
        ok   = "  OK"
    )
    if (isTRUE(hasColor())) {
        stopifnot(requireNamespace("crayon", quietly = TRUE))
        x[["fail"]] <- crayon::red(x[["fail"]])
        x[["note"]] <- crayon::yellow(x[["note"]])
        x[["ok"]] <- crayon::green(x[["ok"]])
    }
    x
}



#' Unordered list
#' @note Updated 2020-06-24.
#' @noRd
ul <- function(x) {
    if (isTRUE(hasCli())) {
        stopifnot(requireNamespace("cli", quietly = TRUE))
        cli::cli_div(theme = list(body = list("margin-left" = 2L)))
        cli::cli_ul(items = x)
        cli::cli_end()
    } else {
        cat(paste0("  - ", x), sep = "\n")
    }
    invisible(x)
}
