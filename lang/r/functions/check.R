## Updated 2020-02-06.
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
    if (isTRUE(required)) {
        fail <- "FAIL"
    } else {
        fail <- "NOTE"
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



## Updated 2020-02-06.
currentMajorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    x <- majorVersion(x)
    x
}



## Updated 2020-02-06.
currentMinorVersion <- function(name) {
    x <- currentVersion(name)
    if (!isTRUE(nzchar(x))) return(character())
    x <- minorVersion(x)
    x
}



## Updated 2020-02-06.
currentVersion <- function(name) {
    script <- file.path(
        Sys.getenv("KOOPA_PREFIX"),
        "system",
        "include",
        "version",
        paste0(name, ".sh")
    )
    stopifnot(isTRUE(file.exists(script)))
    tryCatch(
        expr = system2(command = script, stdout = TRUE, stderr = FALSE),
        warning = function(w) {
            character()
        },
        error = function(e) {
            character()
        }
    )
}



## Updated 2020-02-06.
expectedMajorVersion <- function(x) {
    x <- expectedVersion(x)
    x <- majorVersion(x)
    x
}



## Updated 2020-02-06.
expectedMinorVersion <- function(x) {
    x <- expectedVersion(x)
    stopifnot(isTRUE(grepl("\\.", x)))
    x <- minorVersion(x)
    x
}



## Updated 2020-02-06.
expectedVersion <- function(x) {
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



## Updated 2020-02-06.
hasGNUCoreutils <- function(command = "env") {
    status <- "FAIL"
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
    if (!is.null(x)) {
        x <- head(x, n = 1L)
        x <- grepl("GNU", x)
        if (isTRUE(x)) {
            status <- "  OK"
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



## Updated 2020-02-06.
installed <- function(which, required = TRUE, path = TRUE) {
    stopifnot(
        is.character(which) && !any(is.na(which)),
        isFlag(required),
        isFlag(path)
    )
    if (isTRUE(required)) {
        fail <- "FAIL"
    } else {
        fail <- "NOTE"
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



## Updated 2020-02-06.
isInstalled <- function(which) {
    nzchar(Sys.which(which))
}



## e.g. vim 8
## Updated 2020-02-06.
majorVersion <- function(x) {
    strsplit(x, split = "\\.")[[1L]][[1L]]
}



## e.g. vim 8.1
## Updated 2020-02-06.
minorVersion <- function(x) {
    x <- strsplit(x, split = "\\.")[[1L]]
    x <- paste(x[seq_len(2L)], collapse = ".")
    x
}



## Sanitize complicated verions:
## - 2.7.15rc1 to 2.7.15
## - 1.10.0-patch1 to 1.10.0
## - 1.0.2k-fips to 1.0.2
## Updated 2020-02-06.
sanitizeVersion <- function(x) {
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
