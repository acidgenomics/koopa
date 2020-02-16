## Wrapper for `BiocManager::install()` that skips installed packages.
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
