hasLength <- function(x) {
    length(x) > 0L
}



hasPositionalArgs <- function() {
    hasLength(commandArgs(trailingOnly = TRUE))
}



isSubset <- function(x, y) {
    all(x %in% y)
}



parseArgs <-
    function(required = character(),
             optional = character(),
             flags = character(),
             positional = FALSE) {
        cmdArgs <- commandArgs(trailingOnly = TRUE)
        ## Ensure we strip out quoting from shell handoff.
        cmdArgs <- gsub(
            pattern = "^['\"](.+)['\"]$",
            replacement = "\\1",
            x = cmdArgs
        )
        out <- list(
            required = character(),
            optional = character(),
            flags = character(),
            positional = character()
        )
        if (hasLength(flags)) {
            flagPattern <- "^--([^=[:space:]]+)$"
            flagArgs <- grep(pattern = flagPattern, x = cmdArgs, value = TRUE)
            cmdArgs <- setdiff(cmdArgs, flagArgs)
            flagNames <- sub(
                pattern = flagPattern,
                replacement = "\\1",
                x = flagArgs
            )
            ok <- flagNames %in% flags
            if (!all(ok)) {
                fail <- flagNames[!ok]
                stop(sprintf(
                    "Invalid flags detected: %s.",
                    toInlineString(fail, n = 5L)
                ))
            }
            out[["flags"]] <- flagNames
        }
        if (hasLength(required) || hasLength(optional)) {
            argPattern <- "^--([^=]+)=(.+)$"
            args <- grep(pattern = argPattern, x = cmdArgs, value = TRUE)
            cmdArgs <- setdiff(cmdArgs, args)
            names(args) <- sub(
                pattern = argPattern,
                replacement = "\\1",
                x = args
            )
            args <- sub(pattern = argPattern, replacement = "\\2", x = args)
            args <- sub(
                pattern = "^[\"']",
                replacement = "",
                x = args
            )
            args <- sub(
                pattern = "[\"']$",
                replacement = "",
                x = args
            )
            if (hasLength(required)) {
                ok <- required %in% names(args)
                if (!all(ok)) {
                    fail <- required[!ok]
                    stop(sprintf(
                        "Missing required args: %s.",
                        toString(fail)
                    ))
                }
                out[["required"]] <- args[required]
                args <- args[!names(args) %in% required]
            }
            if (hasLength(optional) && hasLength(args)) {
                match <- match(x = names(args), table = optional)
                if (anyNA(match)) {
                    fail <- names(args)[is.na(match)]
                    stop(sprintf(
                        "Invalid args detected: %s.",
                        toString(fail)
                    ))
                }
                out[["optional"]] <- args
            }
        }
        if (isTRUE(positional)) {
            if (
                !hasLength(cmdArgs) ||
                    any(grepl(pattern = "^--", x = cmdArgs))
            ) {
                stop("Positional arguments are required but missing.")
            }
            out[["positional"]] <- cmdArgs
        } else {
            if (hasLength(cmdArgs)) {
                stop(sprintf(
                    "Positional arguments are defined but not allowed: %s.",
                    toString(cmdArgs)
                ))
            }
        }
        out
    }



positionalArgs <- function() {
    x <- parseArgs(
        required = character(),
        optional = character(),
        flags = character(),
        positional = TRUE
    )
    x[["positional"]]
}



syntacticRename <- function(fun) {
    stopifnot(requireNamespace("syntactic", quietly = TRUE))
    parse <- parseArgs(
        flags = c(
            "dry-run",
            "quiet",
            "recursive"
        ),
        positional = TRUE
    )
    positional <- parse[["positional"]]
    flags <- parse[["flags"]]
    args <- list(
        "path" = unescapePos(positional),
        "recursive" = isSubset("recursive", flags),
        "fun" = fun,
        "quiet" = isSubset("quiet", flags),
        "dryRun" = isSubset("dry-run", flags)
    )
    do.call(what = syntactic::syntacticRename, args = args)
}




unescapePos <- function(x) {
    x <- gsub(
        pattern = "'\\''",
        replacement = "'",
        x = x,
        fixed = TRUE
    )
    x
}
