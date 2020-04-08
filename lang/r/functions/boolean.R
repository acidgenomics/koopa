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



#' Is a system command cellarized?
#' @note Updated 2020-02-29.
isCellar <- function(which) {
    which <- Sys.which(which)
    if (!all(nzchar(which))) return(FALSE)
    which <- normalizePath(which)
    grepl(
        pattern = "/cellar/",
        x = which,
        ignore.case = TRUE
    )
}
