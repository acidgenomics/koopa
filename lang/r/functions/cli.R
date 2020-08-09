.koopaEmoji <- "🐢"



.h <- function(x, level) {
    arrow <- paste0(paste0(rep("=", level), collapse = ""), ">")
    if (isTRUE(hasColor())) {
        requireNamespaces("crayon")
        arrow <- crayon::magenta(arrow)
    }
    cat(paste0(.koopaEmoji, " ", arrow, " ", x, "\n"))
    invisible(x)
}



#' Header 1
#' @note Updated 2020-06-24.
#' @noRd
h1 <- function(x) {
    cat("\n")
    .h(x = x, level = 1L)
}



#' Header 2
#' @note Updated 2020-06-24.
#' @noRd
h2 <- function(x) {
    .h(x = x, level = 2L)
}



#' Header 3
#' @note Updated 2020-06-24.
#' @noRd
h3 <- function(x) {
    .h(x = x, level = 3L)
}



#' Header 4
#' @note Updated 2020-06-24.
#' @noRd
h4 <- function(x) {
    .h(x = x, level = 4L)
}



#' Header 5
#' @note Updated 2020-06-24.
#' @noRd
h5 <- function(x) {
    .h(x = x, level = 5L)
}



#' Header 6
#' @note Updated 2020-06-24.
#' @noRd
h6 <- function(x) {
    .h(x = x, level = 6L)
}



#' Header 7
#' @note Updated 2020-06-24.
#' @noRd
h7 <- function(x) {
    .h(x = x, level = 7L)
}



#' Return status labels, with optional color support
#' @note Updated 2020-08-09.
#' @noRd
status <- function() {
    x <- list(
        fail = "FAIL",
        note = "NOTE",
        ok   = "  OK"
    )
    if (isTRUE(hasColor())) {
        requireNamespaces("crayon")
        x[["fail"]] <- crayon::red(x[["fail"]])
        x[["note"]] <- crayon::yellow(x[["note"]])
        x[["ok"]] <- crayon::green(x[["ok"]])
    }
    x
}



#' Unordered list
#' @note Updated 2020-08-09.
#' @noRd
ul <- function(x) {
    indent <- 4L
    if (isTRUE(hasCli())) {
        requireNamespaces("cli")
        cli::cli_div(theme = list(body = list("margin-left" = indent)))
        cli::cli_ul(items = x)
        cli::cli_end()
    } else {
        cat(paste0(paste0(rep(" ", indent), collapse = ""), "- ", x, "\n"))
    }
    invisible(x)
}
