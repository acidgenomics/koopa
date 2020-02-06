## Updated 2020-02-06.
isFlag <- function(x) {
    is.logical(x) &&
        !any(is.na(x)) &&
        identical(length(x), 1L)
}



## Updated 2020-02-06.
isString <- function(x) {
    is.character(x) && 
        !any(is.na(x)) && 
        identical(length(x), 1L) &&
        isTRUE(nzchar(x))
}
