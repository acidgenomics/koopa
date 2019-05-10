# Check installed program versions.

options(error = quote(quit(status = 1L)))

formals(system)[["intern"]] <- TRUE

check <- function(name, version, required_version) {
    stopifnot(is.character(name))
    version <- package_version(version)
    required_version <- package_version(required_version)
    if (version < required_version) {
        stop(paste(name, version, "<", required_version), call. = FALSE)
    }
}



# Python =======================================================================
# Now requiring >= 3.7. Python 2 will be phased out by 2020.
# The user can use either conda or virtualenv.
version <- system("python --version 2>&1 | head -n 1 | cut -d ' ' -f 2")
required_version <- "3.7"
check("python", version, required_version)



# Vim ==========================================================================
version <- system("vim --version | head -1 | cut -d ' ' -f 5")
required_version <- "8.1"
check("vim", version, required_version)
