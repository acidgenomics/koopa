#' Return status labels, with optional color support
#' @note Updated 2020-02-07.
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



#' Program installation status
#' @note Updated 2020-02-06.
installed <- function(which, required = TRUE, path = TRUE) {
    stopifnot(
        is.character(which) && !any(is.na(which)),
        isFlag(required),
        isFlag(path)
    )
    statusList <- status()
    invisible(vapply(
        X = which,
        FUN = function(which) {
            ok <- nzchar(Sys.which(which))
            if (!isTRUE(ok)) {
                if (isTRUE(required)) {
                    status <- statusList[["fail"]]
                } else {
                    status <- statusList[["note"]]
                }
                message(sprintf(
                    fmt = "  %s | %s missing.",
                    status, which
                ))
            } else {
                status <- statusList[["ok"]]
                msg <- sprintf("  %s | %s", status, which)
                if (isTRUE(path)) {
                    msg <- paste0(
                        msg, "\n",
                        sprintf("       |   %.69s", Sys.which(which))
                    )
                }
                message(msg)
            }
            invisible(ok)
        },
        FUN.VALUE = logical(1L)
    ))
}



#' Check version
#' @note Updated 2020-02-07.
checkVersion <- function(
    name,
    whichName,
    current,
    expected,
    eval = c("==", ">="),
    required = TRUE
) {
    if (missing(whichName)) {
        whichName <- name
    }
    if (identical(current, character())) {
        current <- NA_character_
    }
    stopifnot(
        isString(name),
        isString(whichName) || is.na(whichName),
        is(current, "package_version") ||
            isString(current) ||
            is.na(current),
        is(expected, "package_version") ||
            isString(expected) ||
            is.na(expected),
        isFlag(required)
    )
    eval <- match.arg(eval)
    statusList <- status()
    if (isTRUE(required)) {
        fail <- statusList[["fail"]]
    } else {
        fail <- statusList[["note"]]
    }
    ## Check to see if program is installed.
    if (is.na(current)) {
        message(sprintf(
            fmt = "  %s | %s is not installed.",
            fail, name
        ))
        return(invisible(FALSE))
    }
    ## Normalize the program path, if applicable.
    if (is.na(whichName)) {
        which <- NA_character_
    } else {
        which <- unname(Sys.which(whichName))
        stopifnot(isTRUE(nzchar(which)))
    }
    ## Sanitize the version for non-identical (e.g. GTE) comparisons.
    if (!identical(eval, "==")) {
        if (grepl("\\.", current)) {
            current <- sanitizeVersion(current)
            current <- package_version(current)
        }
        if (grepl("\\.", expected)) {
            expected <- sanitizeVersion(expected)
            expected <- package_version(expected)
        }
    }
    ## Compare current to expected version.
    if (eval == ">=") {
        ok <- current >= expected
    } else if (eval == "==") {
        ok <- current == expected
    }
    if (isTRUE(ok)) {
        status <- statusList[["ok"]]
    } else {
        status <- fail
    }
    msg <- sprintf(
        fmt = "  %s | %s (%s %s %s)",
        status, name,
        current, eval, expected
    )
    if (!is.na(which)) {
        msg <- paste(
            msg,
            sprintf(
                fmt = "       |   %.69s",
                which
            ),
            sep = "\n"
        )
    }
    message(msg)
    invisible(ok)
}



#' Does the system have GNU coreutils installed?
#' @note Updated 2020-02-07.
checkGNUCoreutils <- function(command = "env") {
    stopifnot(isCommand(command))
    statusList <- status()
    x <- tryCatch(
        expr = system2(
            command = command,
            args = "--version",
            stdout = TRUE,
            stderr = FALSE
        ),
        error = function(e) {
            NULL
        }
    )
    status <- statusList[["fail"]]
    if (!is.null(x)) {
        x <- head(x, n = 1L)
        x <- grepl(pattern = "GNU", x = x)
        if (isTRUE(x)) {
            status <- statusList[["ok"]]
        }
    }
    message(sprintf(
        fmt = paste0(
            "  %s | GNU Coreutils\n",
            "       |   %.69s"
        ),
        status,
        dirname(Sys.which("env"))
    ))
}



#' Check Homebrew Cask version
#' @note Updated 2020-02-12.
#'
#' @examples
#' currentHomebrewCaskVersion("gpg-suite")
checkHomebrewCaskVersion <- function(name) {
    invisible(vapply(
        X = name,
        FUN = function(name) {
            checkVersion(
                name = name,
                whichName = NA,
                current = currentHomebrewCaskVersion(name),
                expected = expectedHomebrewCaskVersion(name)
            )
        },
        FUN.VALUE = logical(1L)
    ))
}



#' Check macOS app version
#' @note Updated 2020-02-12.
#'
#' @examples
#' currentMacOSAppVersion(c("BBEdit", "iTerm"))
checkMacOSAppVersion <- function(name) {
    invisible(vapply(
        X = name,
        FUN = function(name) {
            checkVersion(
                name = name,
                whichName = NA,
                current = currentMacOSAppVersion(name),
                expected = expectedMacOSAppVersion(name)
            )
        },
        FUN.VALUE = logical(1L)
    ))
}
