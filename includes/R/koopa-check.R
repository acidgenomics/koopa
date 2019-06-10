# Check installed program versions.
# Note that Ubuntu specific versions are pinned to 18 LTS.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)
formals(warning)[["call."]] <- FALSE

message("koopa system check")

# Operating system name.
# Need to add support for:
# - Arch
# - CentOS
# - Debian
# - Fedora
os <- Sys.getenv("KOOPA_OS_NAME")
stopifnot(isTRUE(nzchar(os)))

host <- Sys.getenv("KOOPA_HOST_NAME")

if (isTRUE(nzchar(Sys.getenv("LINUX")))) {
    linux <- TRUE
} else {
    linux <- FALSE
}

if (isTRUE(nzchar(Sys.getenv("MACOS")))) {
    macos <- TRUE
} else {
    macos <- FALSE
}

pipe <- function(...) {
    paste(..., collapse = " | ")
}

installed <- function(name, required = TRUE) {
    stopifnot(
        is.character(name) && length(name) >= 1L,
        is.logical(required) && length(required) == 1L
    )
    if (isTRUE(required)) {
        fail <- "FAIL"
    } else {
        fail <- "NOTE"
    }
    invisible(vapply(
        X = name,
        FUN = function(name) {
            ok <- nzchar(Sys.which(name))
            if (!isTRUE(ok)) {
                message(paste0("  ", fail, " | ", name, " missing"))
            } else {
                message(paste0("    OK | ", name))
            }
            invisible(ok)
        },
        FUN.VALUE = logical(1L)
    ))
}

check_version <- function(
    name,
    version,
    version_cmd,
    grep_string = NULL,
    eval = c(">=", "=="),
    required = TRUE
) {
    stopifnot(
        is.character(name) && length(name) == 1L,
        is.character(version) && length(version) == 1L,
        is.character(version_cmd),
        (is.character(grep_string) && length(grep_string) == 1L) ||
            is.null(grep_string),
        is.logical(required) && length(required) == 1L
    )
    eval <- match.arg(eval)

    if (isTRUE(required)) {
        fail <- "FAIL"
    } else {
        fail <- "NOTE"
    }

    # Check to see if program is installed.
    if (identical(unname(Sys.which(name)), "")) {
        message(paste0("  ", fail, " | ", name, " missing"))
        return(invisible(FALSE))
    }

    # Grep string check mode.
    if (is.character(grep_string)) {
        x <- system(command = version_cmd[[1L]], intern = TRUE)
        ok <- any(grepl(pattern = grep_string, x = x))
        if (!isTRUE(ok)) {
            message(paste0("  ", fail, " | ", grep_string, " not detected"))
            return(invisible(FALSE))
        }
    }

    if (grepl("\\.", version)) {
        version <- package_version(version)
    }

    # Run the shell system command to extract the program version.
    # Consider switching to `system2()` here in a future update.
    sys_version <- system(command = pipe(version_cmd), intern = TRUE)
    stopifnot(
        is.character(sys_version),
        length(sys_version) == 1L,
        nzchar(sys_version)
    )
    full_sys_version <- sys_version

    # Sanitize complicated verions:
    # - 2.7.15rc1 to 2.7.15
    # - 1.10.0-patch1 to 1.10.0
    # - 1.0.2k-fips to 1.0.2
    sys_version <- sub("-[a-z]+$", "", sys_version)
    sys_version <- sub("\\.([0-9]+)[-a-z]+[0-9]+?$", ".\\1", sys_version)
    sys_version <- sub("^[a-z]+", "", sys_version)
    sys_version <- sub("[a-z]+$", "", sys_version)

    if (grepl("\\.", sys_version)) {
        sys_version <- package_version(sys_version)
    }

    if (eval == ">=") {
        ok <- sys_version >= version
    } else if (eval == "==") {
        ok <- sys_version == version
    }

    if (isTRUE(ok)) {
        status <- "  OK"
    } else {
        status <- fail
    }
    message(paste0(
        "  ", status, " | ", name, " ",
        "(", full_sys_version, " ", eval, " ", version, ")\n",
        "       |   ", Sys.which(name)
    ))
    invisible(ok)
}




# Required =====================================================================
message("\nChecking required programs.")

# Bash
check_version(
    name = "bash",
    version = "5.0.0",
    version_cmd = c(
        "bash --version",
        "head -n 1",
        "cut -d ' ' -f 4",
        "cut -d '(' -f 1"
    ),
    eval = ">="
)

# clang
if (isTRUE(macos)) {
    check_version(
        name = "clang",
        version = "10.0.1",
        version_cmd = c(
            "clang --version",
            "head -n 1",
            "cut -d ' ' -f 4"
        ),
        eval = "=="
    )
}

# GCC
if (isTRUE(linux)) {
    check_version(
        name = "gcc",
        version = "4.8.5",
        version_cmd = c(
            "gcc --version",
            "head -n 1",
            "cut -d ' ' -f 3"
        )
    )
}

# R
# Alternatively, can check using `packageVersion("base")`.
# Using shell version string instead here for consistency.
check_version(
    name = "R",
    version = "3.6.0",
    version_cmd = c(
        "R --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    ),
    eval = "=="
)

# Python
# Now requiring >= 3.7. Python 2 will be phased out by 2020.
# The user can use either conda or virtualenv.
check_version(
    name = "python",
    version = "3.7.3",
    version_cmd = c(
        "python --version 2>&1",
        "head -n 1",
        "cut -d ' ' -f 2"
    ),
    eval = "=="
)

# Perl
# Requiring the current RHEL 7 version.
# The cut match is a little tricky here:
# This is perl 5, version 16, subversion 3 (v5.16.3)
check_version(
    name = "perl",
    version = "5.28.2",
    version_cmd = c(
        "perl --version",
        "sed -n '2p'",
        "cut -d '(' -f 2 | cut -d ')' -f 1"
    ),
    eval = "=="
)

# Emacs
# Setting a hard dependency here, to allow for spacemacs.
check_version(
    name = "emacs",
    version = "26.2",
    version_cmd = c(
        "emacs --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

# Vim
check_version(
    name = "vim",
    version = "8.1",
    version_cmd = c(
        "vim --version",
        "head -1",
        "cut -d ' ' -f 5"
    )
)

# Tmux
check_version(
    name = "tmux",
    version = "2.9",
    version_cmd = c(
        "tmux -V",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# Git
check_version(
    name = "git",
    version = switch(
        EXPR = os,
        ubuntu = "2.17.1",
        "2.21"
    ),
    version_cmd = c(
        "git --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

# GnuPG
check_version(
    name = "gpg",
    version = switch(
        EXPR = os,
        ubuntu = "2.2.4",
        "2.2.8"
    ),
    version_cmd = c(
        "gpg --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

# GSL
check_version(
    name = "gsl-config",
    version = switch(
        EXPR = os,
        ubuntu = "2.4",
        "2.5"
    ),
    version_cmd = c(
        "gsl-config --version",
        "head -n 1"
    )
)

# HDF5
check_version(
    name = "h5dump",
    version = "1.10",
    version_cmd = c(
        "h5dump --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

# htop
check_version(
    name = "htop",
    version = switch(
        EXPR = os,
        ubuntu = "2.1",
        "2.2"
    ),
    version_cmd = c(
        "htop --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# OpenSSL
check_version(
    name = "openssl",
    version = "1.1.1",
    version_cmd = c(
        "openssl version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# Pandoc
check_version(
    name = "pandoc",
    version = switch(
        EXPR = os,
        amzn = "1.12",
        rhel = "1.12",
        "2.0"
    ),
    version_cmd = c(
        "pandoc --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# TeX Live
# Note that we're checking the TeX Live release year here.
# Here's what it looks like on Debian/Ubuntu:
# TeX 3.14159265 (TeX Live 2017/Debian)
check_version(
    name = "tex",
    version = switch(
        EXPR = os,
        amzn = "2013",
        rhel = "2013",
        ubuntu = "2017",
        "2019"
    ),
    version_cmd = c(
        "tex --version",
        "head -n 1",
        "cut -d '(' -f 2",
        "cut -d ')' -f 1",
        "cut -d ' ' -f 3",
        "cut -d '/' -f 1"
    )
)

# ShellCheck
check_version(
    name = "shellcheck",
    version = "0.6",
    version_cmd = c(
        "shellcheck --version",
        "sed -n '2p'",
        "cut -d ' ' -f 2"
    )
)

# rename
# Use Perl File::Rename, not util-linux.
if (isTRUE(linux)) {
    check_version(
        name = "rename",
        version = "1.10",
        version_cmd = c(
            "rename --version",
            "head -n 1",
            "cut -d ' ' -f 5"
        ),
        grep_string = "File::Rename"
    )
} else {
    # Homebrew rename doesn't return version on macOS.
    installed("rename")
}



# Core programs ================================================================
message("\nChecking required core programs.")
installed(c(
    "cat",
    "chsh",
    "curl",
    "echo",
    "env",
    "grep",
    "sed",
    "top",
    "wget",
    "which"
))



# Optional =====================================================================
message("\nChecking optional programs.")

# Z shell
check_version(
    name = "zsh",
    version = "5.7.1",
    version_cmd = c(
        "zsh --version",
        "head -1",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# Conda
check_version(
    name = "conda",
    version = "4.6.14",
    version_cmd = c(
        "conda --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# Linux-specific programs
if (isTRUE(linux)) {
    # RStudio Server
    check_version(
        name = "rstudio-server",
        version = "1.2.1335",
        version_cmd = "rstudio-server version",
        eval = "==",
        required = FALSE
    )

    # Shiny Server
    check_version(
        name = "shiny-server",
        version = "1.5.9.923",
        version_cmd = c(
            "shiny-server --version",
            "head -n 1",
            "cut -d ' ' -f 3"
        ),
        eval = "==",
        required = FALSE
    )
    
    # bcbio_vm.py
    installed("bcbio_vm.py", required = FALSE)

    # bcbio
    check_version(
        name = "bcbio_nextgen.py",
        version = "1.1.3",
        version_cmd = "bcbio_nextgen.py --version",
        eval = switch(
            EXPR = host,
            azure = "==",
            ">="
        ),
        required = FALSE
    )
}
