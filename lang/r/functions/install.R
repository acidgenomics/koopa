#' Install packages
#' @note Updated 2020-02-16.
#'
#' Wrapper for `BiocManager::install()` that skips installed packages.
install <- function(pkgs, ...) {
    invisible(lapply(
        X = pkgs,
        FUN = function(pkg) {
            if (isTRUE(isInstalled(pkg))) return(TRUE)
            stopifnot(requireNamespace("BiocManager", quietly = TRUE))
            BiocManager::install(pkg, ...)
        }
    ))
}



#' Remove packages
#' @note Updated 2020-02-16.
#'
#' Wrapper for `utils::remove.packages()`.
remove <- function(pkgs) {
    stopifnot(requireNamespace("utils", quietly = TRUE))
    pkgs <- intersect(pkgs, rownames(utils::installed.packages()))
    if (length(pkgs) > 0L) {
        message("Removing packages: ", toString(pkgs))
        utils::remove.packages(pkgs = pkgs)
    }
}
