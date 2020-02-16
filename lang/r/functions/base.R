snakeCase <- function(x) {
    gsub(pattern = "\\.", replacement = "_", x = make.names(tolower(x)))
}



#' Kebab case
#' @note Updated 2020-02-12.
kebabCase <- function(x) {
    gsub(pattern = "\\.", replacement = "-", x = make.names(tolower(x)))
}



#' Header 1
#' @note Updated 2020-02-07.
h1 <- function(x) {
    if (isTRUE(hasCli())) {
        stopifnot(requireNamespace("cli", quietly = TRUE))
        cli::cli_h1(x)
    } else {
        message(paste0("\n", x, "\n"))
    }
}



#' Header 2
#' @note Updated 2020-02-07.
h2 <- function(x) {
    if (isTRUE(hasCli())) {
        stopifnot(requireNamespace("cli", quietly = TRUE))
        cli::cat_line()
        cli::cli_h2(x)
    } else {
        message(paste0("\n", x, ":"))
    }
}



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



#' Is an R package installed?
#' @note Updated 2020-02-07.
isInstalled <- function(pkgs) {
    stopifnot(requireNamespace("utils", quietly = TRUE))
    pkgs %in% rownames(installed.packages())
}



#' Major version
#' @note Updated 2020-02-06.
majorVersion <- function(x) {
    strsplit(x, split = "\\.")[[1L]][[1L]]
}



#' Minor version
#' @note Updated 2020-02-06.
minorVersion <- function(x) {
    x <- strsplit(x, split = "\\.")[[1L]]
    x <- paste(x[seq_len(2L)], collapse = ".")
    x
}



#' Sanitize program version
#' @note Updated 2020-02-12.
#'
#' Sanitize complicated verions:
#' - 2.7.15rc1 to 2.7.15
#' - 1.10.0-patch1 to 1.10.0
#' - 1.0.2k-fips to 1.0.2
sanitizeVersion <- function(x) {
    ## Strip anything following a space.
    x <- sub("[[:space:]].+$", "", x)
    ## Strip trailing "+" (e.g. "Python 2.7.15+").
    x <- sub("\\+$", "", x)
    ## Strip quotes (e.g. `java -version` returns '"12.0.1"').
    x <- gsub("\"", "", x)
    ## Strip hyphenated terminator.(e.g. `java -version` returns "1.8.0_212").
    x <- sub("(-|_).+$", "", x)
    x <- sub("\\.([0-9]+)[-a-z]+[0-9]+?$", ".\\1", x)
    ## Strip leading letter.
    x <- sub("^[a-z]+", "", x)
    ## Strip trailing letter.
    x <- sub("[a-z]+$", "", x)
    x
}
