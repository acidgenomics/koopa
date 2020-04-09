#' Can we use cli methods?
#' @note Updated 2020-04-09.
#' @noRd
hasCli <- function() {
    stopifnot(requireNamespace("goalie", quietly = TRUE))
    goalie::isInstalled("cli")
}



#' Can we output color to the console?
#' @note Updated 2020-04-09.
#' @noRd
hasColor <- function() {
    stopifnot(requireNamespace("goalie", quietly = TRUE))
    goalie::isInstalled("crayon")
}



#' Is a system command cellarized?
#' @note Updated 2020-04-09.
#' @noRd
isCellar <- function(which) {
    which <- Sys.which(which)
    if (!all(nzchar(which))) return(FALSE)
    which <- normalizePath(which)
    grepl(pattern = "/cellar/", x = which, ignore.case = TRUE)
}
