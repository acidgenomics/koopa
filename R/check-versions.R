# Check installed program versions.

options(
    error = quote(quit(status = 1L))
    # warning = quote(quit(status = 1L))
)
formals(warning)[["call."]] <- FALSE

# Operating system name.
# Need to add support for:
# - Arch
# - CentOS
# - Debian
# - Fedora
os <- Sys.getenv("KOOPA_OS_NAME")
stopifnot(isTRUE(nzchar(os)))

# Are we running on Linux?
# We're using this for some server-specific checks (e.g. rstudio-server).
if (isTRUE(nzchar(Sys.getenv("LINUX")))) {
    linux <- TRUE
} else {
    linux <- FALSE
}

message("Checking recommended koopa dependencies.")

check <- function(
    name,
    min_version,
    version_cmd
) {
    stopifnot(
        is.character(name),
        is.character(min_version)
    )

    # Check to see if program is installed.
    if (identical(unname(Sys.which(name)), "")) {
        message(paste("FAIL", name, "missing"))
        return(invisible())
    }

    if (grepl("\\.", min_version)) {
        min_version <- package_version(min_version)
    }

    # Run the shell system command to extract the program version.
    # Consider switching to `system2()` here in a future update.
    version <- system(
        command = version_cmd,
        intern = TRUE
    )
    stopifnot(is.character(version))
    orig_version <- version

    # Sanitize complicated verions:
    # - 2.7.15rc1 to 2.7.15
    # - 1.10.0-patch1 to 1.10.0
    # - 1.0.2k-fips to 1.0.2
    version <- sub("-[a-z]+$", "", version)
    version <- sub("\\.([0-9]+)[-a-z]+[0-9]+?$", ".\\1", version)
    version <- sub("^[a-z]+", "", version)
    version <- sub("[a-z]+$", "", version)

    if (grepl("\\.", version)) {
        version <- package_version(version)
    }

    if (version >= min_version) {
        status <- "  OK"
    } else {
	status <- "FAIL"
    }
    message(paste(status, name, orig_version, ">=", min_version))

    invisible()
}

pipe <- function(...) {
    paste(..., sep = " | ")
}



# R ============================================================================
r_version <- packageVersion("base")
r_min_version <- "3.6"
if (r_version >= r_min_version) {
    status <- "  OK"
} else {
    status <- "FAIL"
}
message(paste(status, "R", r_version, ">=", r_min_version))



# Bash =========================================================================
min_version <- switch(
    EXPR = os,
    rhel = "4.2",
    ubuntu = "4.4",
    "5.0"
)
check(
    name = "bash",
    min_version = min_version,
    version_cmd = pipe(
        "bash --version",
        "head -n 1",
        "cut -d ' ' -f 4",
        "cut -d '(' -f 1"
    )
)



# Conda ========================================================================
check(
    name = "conda",
    min_version = "4.6.14",
    version_cmd = pipe(
        "conda --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)



# Emacs ========================================================================
# Setting a hard dependency here, to allow for spacemacs.
check(
    name = "emacs",
    min_version = "26.2",
    version_cmd = pipe(
        "emacs --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)



# Git ==========================================================================
min_version <- switch(
    EXPR = os,
    ubuntu = "2.17.1",
    "2.21"
)
check(
    name = "git",
    min_version = min_version,
    version_cmd = pipe(
        "git --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)



# GnuPG ========================================================================
min_version <- switch(
    EXPR = os,
    ubuntu = "2.2.4",
    "2.2.8"
)
check(
    name = "gpg",
    min_version = min_version,
    version_cmd = pipe(
        "gpg --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)



# GSL ==========================================================================
min_version <- switch(
    EXPR = os,
    ubuntu = "2.4",
    "2.5"
)
check(
    name = "gsl-config",
    min_version = min_version,
    version_cmd = pipe(
        "gsl-config --version",
        "head -n 1"
    )
)



# HDF5 =========================================================================
check(
    name = "h5dump",
    min_version = "1.10",
    version_cmd = pipe(
        "h5dump --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)



# htop =========================================================================
# Ubuntu 18 is still bundling 2.1.
min_version <- switch(
    EXPR = os,
    ubuntu = "2.1",
    "2.2"
)
check(
    name = "htop",
    min_version = min_version,
    version_cmd = pipe(
        "htop --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)



# OpenSSL ======================================================================
# Ubuntu 18 still bundles 1.1.0
# Note that 1.1.1b isn't a valid version in R, so don't check for the letter.
min_version <- switch(
    EXPR = os,
    rhel = "1.0.2",
    ubuntu = "1.1.0",
    "1.1.1"
)
check(
    name = "openssl",
    min_version = min_version,
    version_cmd = pipe(
        "openssl version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)



# Perl =========================================================================
# Requiring the current RHEL 7 version.
# The cut match is a little tricky here:
# This is perl 5, version 16, subversion 3 (v5.16.3)
min_version <- switch(
    EXPR = os,
    rhel = "5.16",
    ubuntu = "5.26",
    "5.28"
)
check(
    name = "perl",
    min_version = min_version,
    version_cmd = pipe(
        "perl --version",
        "sed -n '2p'",
        "cut -d '(' -f 2 | cut -d ')' -f 1"
    )
)



# Python =======================================================================
# Now requiring >= 3.7. Python 2 will be phased out by 2020.
# The user can use either conda or virtualenv.
min_version <- switch(
    EXPR = os,
    rhel = "2.7.5",
    ubuntu = "2.7.15",
    "3.7"
)
check(
    name = "python",
    min_version = min_version,
    version_cmd = pipe(
        "python --version 2>&1",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)



# RStudio Server ===============================================================
if (isTRUE(linux)) {
    check(
        name = "rstudio-server",
        min_version = "1.2.1335",
        version_cmd = "rstudio-server version"
    )
}



# ShellCheck ===================================================================
# RHEL 7 still uses super old 0.3.5 release.
# This is hard to compile, so keep the dependency relaxed.
check(
    name = "shellcheck",
    min_version = "0.6",
    version_cmd = pipe(
        "shellcheck --version",
        "sed -n '2p'",
        "cut -d ' ' -f 2"
    )
)



# TeX Live =====================================================================
# Note that we're checking the TeX Live release year here.
# Here's what it looks like on Debian/Ubuntu:
# TeX 3.14159265 (TeX Live 2017/Debian)
min_version <- switch(
    EXPR = os,
    amzn = "2013",
    rhel = "2013",
    ubuntu = "2017",
    "2019"
)
check(
    name = "tex",
    min_version = min_version,
    version_cmd = pipe(
        "tex --version",
        "head -n 1",
        "cut -d '(' -f 2",
        "cut -d ')' -f 1",
        "cut -d ' ' -f 3",
        "cut -d '/' -f 1"
    )
)



# Tmux =========================================================================
check(
    name = "tmux",
    min_version = "2.9",
    version_cmd = pipe(
        "tmux -V",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)



# Vim ==========================================================================
check(
    name = "vim",
    min_version = "8.1",
    version_cmd = pipe(
        "vim --version",
        "head -1",
        "cut -d ' ' -f 5"
    )
)



# Z shell ======================================================================
check(
    name = "zsh",
    min_version = "5.7.1",
    version_cmd = pipe(
        "zsh --version",
        "head -1",
        "cut -d ' ' -f 2"
    )
)
