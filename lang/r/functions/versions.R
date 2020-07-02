#' Current Homebrew Cask version
#' @note Updated 2020-02-12.
#' @noRd
currentHomebrewCaskVersion <- function(name) {
    currentVersion(name = name, fun = "get-homebrew-cask-version")
}



#' Current macOS app version
#' @note Updated 2020-04-09.
#' @noRd
currentMacOSAppVersion <- function(name) {
    x <- currentVersion(name = name, fun = "get-macos-app-version")
    ## Ensure build information gets stripped.
    ## e.g. Tunnelblick: (build 5400).
    stopifnot(requireNamespace("acidbase", quietly = TRUE))
    x <- acidbase::sanitizeVersion(x)
    x
}



#' Current major version
#' @note Updated 2020-04-09.
#' @noRd
currentMajorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    stopifnot(requireNamespace("acidbase", quietly = TRUE))
    x <- acidbase::majorVersion(x)
    x
}



#' Current minor version
#' @note Updated 2020-04-09.
#' @noRd
currentMinorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    stopifnot(requireNamespace("acidbase", quietly = TRUE))
    x <- acidbase::minorVersion(x)
    x
}



#' Current version of installed program
#' @note Updated 2020-04-12.
#' @noRd
currentVersion <- function(name, fun = "get-version") {
    # Ensure spaces are escaped.
    name <- paste0("'", name, "'")
    command <- get(x = "koopa", envir = .koopa, inherits = FALSE)
    tryCatch(
        ## Note that `koopa` here is a global variable to koopa script path.
        expr = system2(
            command = command,
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
#' @note Updated 2020-04-09.
#' @noRd
expectedMajorVersion <- function(x) {
    x <- expectedVersion(x)
    stopifnot(requireNamespace("acidbase", quietly = TRUE))
    x <- acidbase::majorVersion(x)
    x
}



#' Expected minor version
#' @note Updated 2020-04-09.
expectedMinorVersion <- function(x) {
    x <- expectedVersion(x)
    stopifnot(isTRUE(grepl("\\.", x)))
    stopifnot(requireNamespace("acidbase", quietly = TRUE))
    x <- acidbase::minorVersion(x)
    x
}



#' Expected version
#' @note Updated 2020-07-02.
#' @noRd
expectedVersion <- function(x) {
    stopifnot(requireNamespace("syntactic", quietly = TRUE))
    x <- syntactic::kebabCase(x)
    variablesFile <- file.path(
        .koopa[["prefix"]],
        "include",
        "variables.txt"
    )
    variables <- readLines(variablesFile)
    keep <- grepl(pattern = paste0("^", x, "="), x = variables)
    stopifnot(sum(keep, na.rm = TRUE) == 1L)
    x <- variables[keep]
    stopifnot(isTRUE(nzchar(x)))
    x <- sub(pattern = "^(.+)=\"(.+)\"$", replacement = "\\2", x = x)
    x
}
