#' Kebab case
#' @note Updated 2020-02-12.
kebabCase <- function(x) {
    gsub(pattern = "\\.", replacement = "-", x = make.names(tolower(x)))
}



#' Snake case
#' @note Updated 2020-02-12.
snakeCase <- function(x) {
    gsub(pattern = "\\.", replacement = "_", x = make.names(tolower(x)))
}
