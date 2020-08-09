#' Rename files in camel case
#' @note Updated 2020-08-09.
renameCamelCase <- function() {
    requireNamespaces("syntactic")
    args <- parseArgs(
        flags = c("prefix", "recursive", "strict"),
        positionalArgs = TRUE
    )
    posArgs <- args[["positionalArgs"]]
    prefix <- "prefix" %in% args[["flags"]]
    recursive <- "recursive" %in% args[["flags"]]
    strict <- "strict" %in% args[["flags"]]
    syntactic::camelCase(
        object = posArgs,
        rename = TRUE,
        recursive = recursive,
        strict = strict,
        prefix = prefix
    )
}

#' Rename files in kebab case
#' @note Updated 2020-08-09.
renameKebabCase <- function() {
    requireNamespaces("syntactic")
    args <- parseArgs(
        flags = c("prefix", "recursive"),
        positionalArgs = TRUE
    )
    posArgs <- args[["positionalArgs"]]
    prefix <- "prefix" %in% args[["flags"]]
    recursive <- "recursive" %in% args[["flags"]]
    syntactic::kebabCase(
        object = posArgs,
        rename = TRUE,
        recursive = recursive,
        prefix = prefix
    )
}

#' Rename files in snake case
#' @note Updated 2020-08-09.
renameSnakeCase <- function() {
    requireNamespaces("syntactic")
    args <- parseArgs(
        flags = c("prefix", "recursive"),
        positionalArgs = TRUE
    )
    posArgs <- args[["positionalArgs"]]
    prefix <- "prefix" %in% args[["flags"]]
    recursive <- "recursive" %in% args[["flags"]]
    syntactic::snakeCase(
        object = posArgs,
        rename = TRUE,
        recursive = recursive,
        prefix = prefix
    )
}
