#' Current Homebrew Cask version
#' @note Updated 2020-02-12.
#' @noRd
currentHomebrewCaskVersion <- function(name) {
    currentVersion(name = name, fun = "get-homebrew-cask-version")
}



#' Current macOS app version
#'
#' Ensures build information gets stripped.
#' e.g. Tunnelblick: (build 5400).
#' @note Updated 2020-08-09.
#' @noRd
currentMacOSAppVersion <- function(name) {
    x <- currentVersion(name = name, fun = "get-macos-app-version")
    x <- sanitizeVersion(x)
    x
}



#' Current major version
#' @note Updated 2020-08-09.
#' @noRd
currentMajorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    x <- majorVersion(x)
    x
}



#' Current minor version
#' @note Updated 2020-08-09.
#' @noRd
currentMinorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    x <- minorVersion(x)
    x
}



#' Current version of installed program
#' @note Updated 2020-08-09.
#' @noRd
currentVersion <- function(name, fun = "get-version") {
    tryCatch(
        expr = shell(
            command = koopa,
            args = c(
                fun,
                paste0("'", name, "'")
            ),
            stdout = TRUE,
            stderr = FALSE
        ),
        warning = function(w) {
            character()
        },
        error = function(e) {
            character()
        }
    )
}



#' Expected Homebrew Cask version
#' @note Updated 2020-02-12.
#' @noRd
expectedHomebrewCaskVersion <- function(x) {
    expectedVersion(paste0("homebrew-cask-", x))
}



#' Expected macOS app version
#' @note Updated 2020-04-12.
#' @noRd
expectedMacOSAppVersion <- function(x) {
    expectedVersion(x = paste0("macos-app-", tolower(x)))
}



#' Expected major version
#' @note Updated 2020-08-09.
#' @noRd
expectedMajorVersion <- function(x) {
    x <- expectedVersion(x)
    x <- majorVersion(x)
    x
}



#' Expected minor version
#' @note Updated 2020-08-09.
expectedMinorVersion <- function(x) {
    x <- expectedVersion(x)
    assert(isTRUE(grepl("\\.", x)))
    x <- minorVersion(x)
    x
}



#' Expected version
#' @note Updated 2020-08-09.
#' @noRd
expectedVersion <- function(x) {
    requireNamespaces("syntactic")
    x <- syntactic::kebabCase(x)
    variablesFile <- file.path(
        .koopa[["prefix"]],
        "include",
        "variables.txt"
    )
    variables <- readLines(variablesFile)
    keep <- grepl(pattern = paste0("^", x, "="), x = variables)
    assert(sum(keep, na.rm = TRUE) == 1L)
    x <- variables[keep]
    assert(isTRUE(nzchar(x)))
    x <- sub(pattern = "^(.+)=\"(.+)\"$", replacement = "\\2", x = x)
    x
}
