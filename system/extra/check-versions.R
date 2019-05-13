# Check installed program versions.

# options(
#     error = quote(quit(status = 1L)),
#     warning = quote(quit(status = 1L))
# )

check <- function(
    name,
    min_version,
    version_cmd
) {
    stopifnot(
        is.character(name),
        is.character(min_version)
    )
    inform <- warning
    formals(inform)[["call."]] <- FALSE

    # Check to see if program is installed.
    if (identical(unname(Sys.which(name)), "")) {
        inform(paste(name, "missing"))
        return(invisible())
    }

    min_version <- package_version(min_version)

    # Run the shell system command to extract the program version.
    # Consider switching to `system2()` here in a future update.
    version <- system(
        command = version_cmd,
        intern = TRUE
    )
    stopifnot(is.character(version))

    # Strip leading and trailing characters (e.g. "v/a") if necessary.
    version <- sub("^[a-z]+", "", version)
    version <- sub("[a-z]+$", "", version)
    version <- package_version(version)

    if (version < min_version) {
        inform(paste(name, version, "<", min_version))
    }
}

pipe <- function(...) {
    paste(..., sep = " | ")
}

check(
    name = "emacs",
    min_version = "26.2",
    version_cmd = pipe(
        "emacs --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

check(
    name = "git",
    min_version = "2.21",
    version_cmd = pipe(
        "git --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

check(
    name = "gpg",
    min_version = "2.2.8",
    version_cmd = pipe(
        "gpg --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

check(
    name = "gsl-config",
    min_version = "2.5",
    version_cmd = pipe(
        "gsl-config --version",
        "head -n 1"
    )
)

check(
    name = "h5dump",
    min_version = "1.10",
    version_cmd = pipe(
        "h5dump --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

check(
    name = "htop",
    min_version = "2.2.0",
    version_cmd = pipe(
        "htop --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# Note that 1.1.1b isn't a valid version in R, so don't check for the letter.
check(
    name = "openssl",
    min_version = "1.1.1",
    version_cmd = pipe(
        "openssl version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# Requiring the current RHEL 7 version.
# The cut match is a little tricky here:
# This is perl 5, version 16, subversion 3 (v5.16.3)
check(
    name = "perl",
    min_version = "5.16.3",
    version_cmd = pipe(
        "perl --version",
        "sed -n '2p'",
        "cut -d '(' -f 2 | cut -d ')' -f 1"
    )
)

# Now requiring >= 3.7. Python 2 will be phased out by 2020.
# The user can use either conda or virtualenv.
check(
    name = "python",
    min_version = "3.7",
    version_cmd = pipe(
        "python --version 2>&1",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# RHEL 7 still uses super old 0.3.5 release.
# This is hard to compile, so keep the dependency relaxed.
check(
    name = "shellcheck",
    min_version = "0.3.5",
    version_cmd = pipe(
        "shellcheck --version",
        "sed -n '2p'",
        "cut -d ' ' -f 2"
    )
)

check(
    name = "tmux",
    min_version = "2.9",
    version_cmd = pipe(
        "tmux -V",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

check(
    name = "vim",
    min_version = "8.1",
    version_cmd = pipe(
        "vim --version",
        "head -1",
        "cut -d ' ' -f 5"
    )
)
