#' Can we use cli methods?
#' @note Updated 2020-02-16.
hasCli <- function() {
    isInstalled("cli")
}



#' Can we output color to the console?
#' @note Updated 2020-02-16.
hasColor <- function() {
    isInstalled("crayon")
}



#' Is a system command installed?
#' @note Updated 2020-02-06.
isCommand <- function(which) {
    nzchar(Sys.which(which))
}



#' Is flag?
#' @note Updated 2020-02-06.
isFlag <- function(x) {
    is.logical(x) &&
        !any(is.na(x)) &&
        identical(length(x), 1L)
}



#' Is an R package installed?
#' @note Updated 2020-02-07.
isInstalled <- function(pkgs) {
    stopifnot(requireNamespace("utils", quietly = TRUE))
    pkgs %in% rownames(installed.packages())
}



#' Is macOS?
#' @note Updated 2020-02-07.
isMacOS <- function() {
    grepl(pattern = "darwin", x = R.Version()[["os"]])
}



#' Is string?
#' @note Updated 2020-02-09.
isString <- function(x) {
    is.character(x) &&
        !any(is.na(x)) &&
        identical(length(x), 1L) &&
        isTRUE(nzchar(x))
}
