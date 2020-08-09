#' Parse command line argument flags
#'
#' @export
#' @note Updated 2020-08-09.
#'
#' @param requiredArgs,optionalArgs `character` or `NULL`.
#'   Valid key-value pair argument names.
#'   For example, `aaa` for `--aaa=AAA` or `--aaa AAA`.
#'   Note that `--aaa AAA`-style arguments (note lack of `=`) are not currently
#'   supported.
#' @param flags `character` or `NULL`.
#'   Valid long flag names.
#'   For example, `aaa` for `--aaa`.
#'   Short flags, such as `-r`, are intentionally not supported.
#' @param positionalArgs `logical(1)`.
#'   Require positional arguments to be defined.
#'
#' @return `list`.
#'   Named list containing arguments, organized by type:
#'   - `requiredArgs`
#'   - `optionalArgs`
#'   - `flags`
#'   - `positionalArgs`
#'
#' @seealso
#' - argparse Python package.
#' - argparser R package.
#' - optparse R package.
#'
#' @examples
#' command <- system.file("scripts", "parse-args", package = "acidbase")
#' args <- c(
#'     ## Required args:
#'     "--aaa=AAA", "--bbb=BBB",
#'     ## Optional args:
#'     "--ccc=CCC", "--ddd=DDD",
#'     ## Flags:
#'     "--eee", "--fff",
#'     ## Positional args:
#'     "GGG", "HHH"
#' )
#' readLines(command)
#' out <- shell(command = command, args = args, stdout = TRUE)
#' print(out)
parseArgs <- function(
    requiredArgs = NULL,
    optionalArgs = NULL,
    flags = NULL,
    positionalArgs = FALSE
) {
    assert(
        !hasLength(intersect(requiredArgs, optionalArgs)),
        !hasLength(intersect(requiredArgs, flags)),
        !hasLength(intersect(optionalArgs, flags))
    )
    cmdArgs <- commandArgs(trailingOnly = TRUE)
    out <- list(
        requiredArgs = NULL,
        optionalArgs = NULL,
        flags = NULL,
        positionalArgs = NULL
    )
    if (!is.null(flags)) {
        optionalFlags <- flags
        flagPattern <- "^--([^=[:space:]]+)$"
        flags <- grep(pattern = flagPattern, x = cmdArgs, value = TRUE)
        cmdArgs <- setdiff(cmdArgs, flags)
        flags <- sub(pattern = flagPattern, replacement = "\\1", x = flags)
        ok <- flags %in% optionalFlags
        if (!all(ok)) {
            fail <- flags[!ok]
            stop(sprintf(
                "Invalid flags detected: %s.",
                toString(fail, width = 200L)
            ))
        }
        out[["flags"]] <- flags
    }
    if (!is.null(requiredArgs) || !is.null(optionalArgs)) {
        argPattern <- "^--([^=[:space:]]+)=([^[:space:]]+)$"
        args <- grep(pattern = argPattern, x = cmdArgs, value = TRUE)
        cmdArgs <- setdiff(cmdArgs, args)
        names(args) <- sub(pattern = argPattern, replacement = "\\1", x = args)
        args <- sub(pattern = argPattern, replacement = "\\2", x = args)
        if (!is.null(requiredArgs)) {
            ok <- requiredArgs %in% names(args)
            if (!all(ok)) {
                fail <- requiredArgs[!ok]
                stop(sprintf(
                    "Missing required args: %s.",
                    toString(fail, width = 200L)
                ))
            }
            out[["requiredArgs"]] <- args[requiredArgs]
            args <- args[!names(args) %in% requiredArgs]
        }
        if (!is.null(optionalArgs) && hasLength(args)) {
            match <- match(x = names(args), table = optionalArgs)
            if (any(is.na(match))) {
                fail <- names(args)[is.na(match)]
                stop(sprintf(
                    "Invalid args detected: %s.",
                    toString(fail, width = 200L)
                ))
            }
            out[["optionalArgs"]] <- args
        }
    }
    if (isTRUE(positionalArgs)) {
        if (!hasLength(cmdArgs) || any(grepl(pattern = "^--", x = cmdArgs))) {
            stop("Positional arguments are required but missing.")
        }
        out[["positionalArgs"]] <- cmdArgs
    } else {
        if (hasLength(cmdArgs)) {
            stop(sprintf(
                "Positional arguments are defined but not allowed: %s.",
                toString(cmdArgs, width = 200L)
            ))
        }
    }
    out
}



#' @rdname parseArgs
#' @export
positionalArgs <- function() {
    x <- parseArgs(
        requiredArgs = NULL,
        optionalArgs = NULL,
        flags = NULL,
        positionalArgs = TRUE
    )
    x[["positionalArgs"]]
}
