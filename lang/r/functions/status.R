#' Can we output color to the console?
#' @note Updated 2020-02-07.
hasColor <- function() {
    isPackage("crayon")
}



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



## FIXME REWORK STATUS LABEL HANDLING

#' Check version
#' @note Updated 2020-02-06.
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
    hasColor <- hasColor()
    if (isTRUE(required)) {
        fail <- "FAIL"
        if (isTRUE(hasColor)) {
            fail <- crayon::red(fail)
        }
    } else {
        fail <- "NOTE"
        if (isTRUE(hasColor)) {
            fail <- crayon::red(fail)
        }
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
        status <- "  OK"
        if (isTRUE(hasColor)) {
            status <- crayon::green(status)
        }
    } else {
        status <- fail
    }
    message(
        sprintf(
            fmt = paste0(
                "  %s | %s (%s %s %s)\n",
                "       |   %.69s"
            ),
            status, name,
            current, eval, expected,
            which
        )
    )
    invisible(ok)
}



## FIXME REWORK STATUS LABEL HANDLING

#' Does the system have GNU coreutils installed?
#' @note Updated 2020-02-06.
checkGNUCoreutils <- function(command = "env") {
    stopifnot(isCommand(command))
    hasColor <- hasColor()
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
    status <- "FAIL"
    if (isTRUE(hasColor)) {
        status <- crayon::red(status)
    }
    if (!is.null(x)) {
        x <- head(x, n = 1L)
        x <- grepl(pattern = "GNU", x = x)
        if (isTRUE(x)) {
            status <- "  OK"
            if (isTRUE(hasColor)) {
                status <- crayon::green(status)
            }
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



## FIXME REWORK STATUS LABEL HANDLING

#' Program installation status
#' @note Updated 2020-02-06.
installed <- function(which, required = TRUE, path = TRUE) {
    stopifnot(
        is.character(which) && !any(is.na(which)),
        isFlag(required),
        isFlag(path)
    )
    hasColor <- hasColor()

    ## FIXME Convert this to a function...put into a list.
    statusOK <- "  OK"
    if (isTRUE(hasColor)) {
        statusOK <- crayon::green(statusOK)
    }
    if (isTRUE(required)) {
        statusFail <- "FAIL"
        if (isTRUE(hasColor)) {
            statusFail <- crayon::red(statusFail)
        }
    } else {
        statusNote <- "NOTE"
        if (isTRUE(hasColor)) {
            fail <- crayon::yellow(fail)
        }
    }

    invisible(vapply(
        X = which,
        FUN = function(which) {
            ok <- nzchar(Sys.which(which))
            if (!isTRUE(ok)) {
                message(sprintf(
                    fmt = "  %s | %s missing.",
                    fail, which
                ))
            } else {
                msg <- sprintf("    OK | %s", which)
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
