#' Rename files in camel case
#' @note Updated 2020-08-09.
renameCamelCase <- function() {
    requireNamespaces("syntactic")
    prefix <- FALSE
    recursive <- FALSE
    strict <- FALSE
    ## FIXME REWORK THIS.
    args <- parseArgs(
        positional = TRUE,
        optionalFlags = c("prefix", "recursive", "strict")
    )
    if ("--prefix" %in% args) {
        prefix <- TRUE
    }
    if ("--recursive" %in% args) {
        recursive <- TRUE
    }
    if ("--strict" %in% args) {
        strict <- TRUE
    }
    syntactic::camelCase(
        object = posArgs,
        rename = TRUE,
        recursive = recursive,
        strict = strict,
        prefix = prefix
    )
}

#' Rename files in kebab case
#' @note Updated 2020-08-05.
renameKebabCase <- function() {
    requireNamespaces("syntactic")
    prefix <- FALSE
    recursive <- FALSE
    args <- parseArgs(
        positional = TRUE,
        validFlags = c("prefix", "recursive")
    )
    if ("--prefix" %in% args) {
        prefix <- TRUE
    }
    if ("--recursive" %in% args) {
        recursive <- TRUE
    }
    syntactic::kebabCase(
        object = positionalArgs(),
        rename = TRUE,
        recursive = recursive,
        prefix = prefix
    )
}

#' Rename files in snake case
#' @note Updated 2020-08-05.
renameSnakeCase <- function() {
    requireNamespaces("syntactic")
    prefix <- FALSE
    recursive <- FALSE
    args <- parseArgs(
        positional = TRUE,
        validFlags = c("prefix", "recursive")
    )
    if ("--prefix" %in% args) {
        prefix <- TRUE
    }
    if ("--recursive" %in% args) {
        recursive <- TRUE
    }
    syntactic::snakeCase(
        object = positionalArgs(),
        rename = TRUE,
        recursive = recursive,
        prefix = prefix
    )
}
