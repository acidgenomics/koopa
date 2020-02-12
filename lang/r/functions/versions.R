## Current ====================================================================
#' Current version of installed program
#' @note Updated 2020-02-12.
#'
#' Be aware that current 'Renviron.site' configuration restricts PATH so that
#' koopa installation is not visible in R.
#'
#' Our internal 'check.R' script runs with '--vanilla' flag to avoid this.
currentVersion <- function(name, fun = "get-version") {
    stopifnot(isCommand("koopa"))
    # Ensure spaces are escaped.
    name <- paste0("'", name, "'")
    tryCatch(
        expr = system2(
            command = "koopa",
            args = c(fun, name),
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



#' Current Homebrew Cask version
#' @note Updated 2020-02-12.
currentHomebrewCaskVersion <- function(name) {
    currentVersion(name = name, fun = "get-homebrew-cask-version")
}



#' Current macOS app version
#' @note Updated 2020-02-12.
currentMacOSAppVersion <- function(name) {
    currentVersion(name = name, fun = "get-macos-app-version")
}



#' Current major version
#' @note Updated 2020-02-06.
currentMajorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    x <- majorVersion(x)
    x
}



#' Current minor version
#' @note Updated 2020-02-06.
currentMinorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    x <- minorVersion(x)
    x
}



## Expected ====================================================================
#' Expected version
#' @note Updated 2020-02-11.
expectedVersion <- function(x) {
    x <- kebabCase(x)
    variablesFile <- file.path(
        Sys.getenv("KOOPA_PREFIX"),
        "system",
        "include",
        "variables.txt"
    )
    variables <- readLines(variablesFile)
    keep <- grepl(pattern = paste0("^", x, "="), x = variables)
    stopifnot(sum(keep, na.rm = TRUE) == 1L)
    x <- variables[keep]
    stopifnot(isTRUE(nzchar(x)))
    x <- sub(
        pattern = "^(.+)=\"(.+)\"$",
        replacement = "\\2",
        x = x
    )
    x
}



#' Expected Homebrew Cask version
#' @note Updated 2020-02-12.
expectedHomebrewCaskVersion <- function(x) {
    expectedVersion(paste0("homebrew-cask-", x))
}



#' Expected macOS app version
#' @note Updated 2020-02-12.
expectedMacOSAppVersion <- function(x) {
    expectedVersion(paste0("macos-app-", x))
}



#' Expected major version
#' @note Updated 2020-02-06.
expectedMajorVersion <- function(x) {
    x <- expectedVersion(x)
    x <- majorVersion(x)
    x
}



#' Expected minor version
#' @note Updated 2020-02-06.
expectedMinorVersion <- function(x) {
    x <- expectedVersion(x)
    stopifnot(isTRUE(grepl("\\.", x)))
    x <- minorVersion(x)
    x
}
