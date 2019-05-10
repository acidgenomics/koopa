# Check installed program versions.

options(error = quote(quit(status = 1L)))

# Consider switching to `system2()` in a future update.
formals(system)[["intern"]] <- TRUE

check <- function(name, version, required_version) {
    stopifnot(is.character(name))
    # Strip trailing character (e.g. "a") if necessary.
    version <- sub("[a-z]+$", "", version)
    version <- package_version(version)
    required_version <- package_version(required_version)
    if (version < required_version) {
        stop(paste(name, version, "<", required_version), call. = FALSE)
    }
}



# Emacs ========================================================================
name <- "Emacs"
version <- system("emacs --version | head -n 1 | cut -d ' ' -f 3")
required_version <- "26.2"
check(name, version, required_version)



# Git ==========================================================================
name <- "Git"
version <- system("git --version | head -n 1 | cut -d ' ' -f 3")
required_version <- "2.21"
check(name, version, required_version)



# GnuPG ========================================================================
name <- "GnuPG"
version <- system("gpg --version | head -n 1 | cut -d ' ' -f 3")
required_version <- "2.2.8"
check(name, version, required_version)



# GSL ==========================================================================
name <- "GSL"
version <- system("gsl-config --version | head -n 1")
required_version <- "2.5"
check(name, version, required_version)



# HDF5 =========================================================================
name <- "HDF5"
version <- system("h5dump --version | head -n 1 | cut -d ' ' -f 3")
required_version <- "1.10"
check(name, version, required_version)



# htop =========================================================================
name <- "htop"
version <- system("htop --version | head -n 1 | cut -d ' ' -f 2")
required_version <- "2.2.0"
check(name, version, required_version)



# Python =======================================================================
# Now requiring >= 3.7. Python 2 will be phased out by 2020.
# The user can use either conda or virtualenv.
name <- "Python"
version <- system("python --version 2>&1 | head -n 1 | cut -d ' ' -f 2")
required_version <- "3.7"
check(name, version, required_version)



# ShellCheck ===================================================================
# RHEL 7 still uses super old 0.3.5 release.
name <- "ShellCheck"
version <- system("shellcheck --version | sed -n '2p' | cut -d ' ' -f 2")
required_version <- "0.3.5"
check(name, version, required_version)



# tmux =========================================================================
name <- "tmux"
version <- system("tmux -V | head -n 1 | cut -d ' ' -f 2")
required_version <- "2.9"
check(name, version, required_version)



# Vim ==========================================================================
name <- "Vim"
version <- system("vim --version | head -1 | cut -d ' ' -f 5")
required_version <- "8.1"
check(name, version, required_version)
