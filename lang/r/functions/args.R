#' Help
#'
#' Display help via `man` when `--help` or `-h` flag is detected.
#'
#' @note Updated 2020-02-01.
#' @noRd
#'
#' @return System command when `--help` is set, or invisible `NULL`.
koopaHelp <- function() {
    args <- commandArgs(trailingOnly = FALSE)
    if (!isTRUE(any(c("--help", "-h") %in% args))) {
        return(invisible())
    }
    file <- grep(pattern = "--file", x = args)
    file <- args[file]
    file <- sub(pattern = "^--file=", replacement = "", x = file)
    name <- basename(file)
    system2(command = "man", args = name)
    quit()
}



#' Parse argument flags
#'
#' @note Updated 2020-02-02.
#' @noRd
#'
#' @return `character`.
#'   Arguments.
parseArgs <- function(
    positional = FALSE,
    validArgs = NULL,
    validFlags = NULL
) {
    if (isTRUE(positional)) {
        posArgs <- positionalArgs()
        if (length(posArgs) == 0L) {
            stop("Required positional arguments are missing.")
        }
    }
    args <- commandArgs(trailingOnly = FALSE)
    keep <- grepl(pattern = "^--", x = args)
    x <- args[keep]
    x <- setdiff(x = x, y = c("--args", "--no-restore", "--slave"))
    ## Always drop the file argument in this parser.
    keep <- !grepl(pattern = "^--file=", x = x)
    x <- x[keep]
    ## Check for valid arguments.
    if (!is.null(validArgs) || !is.null(validFlags)) {
        ## Get the argument names (`--a="XXX"` to "a").
        pattern <- "^--([-a-z0-9]+)=.+$"
        keep <- grepl(pattern = pattern, x = x)
        args <- x[keep]
        argNames <- gsub(pattern = pattern, replacement = "\\1", x = args)
        stopifnot(!any(duplicated(argNames)))
        ## Get the flag names (`--a` to "a").
        keep <- grepl(pattern = "^--[-a-z0-9]+$", x = x)
        flags <- x[keep]
        flagNames <- gsub(pattern = "^--", replacement = "", x = flags)
        stopifnot(
            !any(duplicated(flagNames)),
            length(intersect(argNames, flagNames)) == 0L,
            length(intersect(argNames, validFlags)) == 0L,
            length(intersect(flagNames, validArgs)) == 0L
        )
    }
    ## Check for valid arguments.
    if (!is.null(validArgs)) {
        if (!all(argNames %in% validArgs)) {
            invalid <- setdiff(argNames, validArgs)
            stop(sprintf(
                fmt = "Invalid %s: '%s'.",
                ngettext(
                    n = length(invalid),
                    msg1 = "arg",
                    msg2 = "args"
                ),
                toString(invalid)
            ))
        }
    }
    ## Check for valid flags.
    if (!is.null(validFlags)) {
        if (!all(flagNames %in% validFlags)) {
            invalid <- setdiff(flagNames, validFlags)
            stop(sprintf(
                fmt = "Invalid %s: '%s'.",
                ngettext(
                    n = length(invalid),
                    msg1 = "flag",
                    msg2 = "flags"
                ),
                toString(invalid)
            ))
        }
    }
    ## Return arguments.
    x
}



#' Positional arguments
#'
#' These arguments do not contain `--` prefixes.
#'
#' @note Updated 2020-02-20.
#' @noRd
positionalArgs <- function() {
    trailingArgs <- commandArgs(trailingOnly = TRUE)
    keep <- !grepl(pattern = "^--", x = trailingArgs)
    trailingArgs[keep]
}
