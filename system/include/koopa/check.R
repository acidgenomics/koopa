#!/usr/bin/env -S Rscript --vanilla
# shebang requires env from coreutils >= 8.30.

# Check installed program versions.
# Modified 2019-06-24.

# Note: Ubuntu specific versions are currently pinned to 18 LTS.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)

koopa_exe <- file.path(Sys.getenv("KOOPA_HOME"), "bin", "koopa")
stopifnot(file.exists(koopa_exe))

host <- system(command = paste(koopa_exe, "host-name"), intern = TRUE)
os <- system(command = paste(koopa_exe, "os-name"), intern = TRUE)

r_os_string <- R.Version()[["os"]]
if (grepl("darwin", r_os_string)) {
    linux <- FALSE
} else {
    linux <- TRUE
}

variables_file <- file.path(
    Sys.getenv("KOOPA_HOME"),
    "system",
    "include",
    "variables.txt"
)
variables <- readLines(variables_file)

koopa_version <- function(x) {
    keep <- grepl(pattern = paste0("^", x, "="), x = variables)
    stopifnot(sum(keep, na.rm = TRUE) == 1L)
    string <- variables[keep]
    sub(
        pattern = "^(.+)=\"(.+)\"$",
        replacement = "\\2",
        x = string
    )
}

major_koopa_version <- function(x) {
    x <- koopa_version(x)
    x <- sanitize_version(x)
    x <- package_version(x)
    x <- as.character(x)
    x <- gsub("^(.+)\\.(.+)\\.(.+)$", "\\1.\\2", x)
    x
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
                message(paste0(
                    "    OK | ", name, "\n",
                    "       |   ", Sys.which(name)
                ))
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
    which <- unname(Sys.which(name))
    if (identical(which, "")) {
        message(paste0("  ", fail, " | ", name, " missing"))
        return(invisible(FALSE))
    }
    which <- normalizePath(which)

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
        version <- sanitize_version(version)
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

    if (grepl("\\.", sys_version)) {
        sys_version <- sanitize_version(sys_version)
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
        "       |   ", which
    ))
    invisible(ok)
}

# Sanitize complicated verions:
# - 2.7.15rc1 to 2.7.15
# - 1.10.0-patch1 to 1.10.0
# - 1.0.2k-fips to 1.0.2
sanitize_version <- function(x) {
    # Strip trailing "+" (e.g. "Python 2.7.15+").
    x <- sub("\\+$", "", x)
    # Strip quotes (e.g. `java -version` returns '"12.0.1"').
    x <- gsub("\"", "", x)
    # Strip hyphenated terminator.(e.g. `java -version` returns "1.8.0_212").
    x <- sub("(-|_).+$", "", x)
    x <- sub("\\.([0-9]+)[-a-z]+[0-9]+?$", ".\\1", x)
    # Strip leading letter.
    x <- sub("^[a-z]+", "", x)
    # Strip trailing letter.
    x <- sub("[a-z]+$", "", x)
    x
}



# Required =====================================================================
message("\nChecking required programs.")

# Bash
check_version(
    name = "bash",
    version = switch(
        EXPR = os,
        darwin = "5.0.7",
        koopa_version("bash")
    ),
    version_cmd = c(
        "bash --version",
        "head -n 1",
        "cut -d ' ' -f 4",
        "cut -d '(' -f 1"
    ),
    eval = "=="
)

# R
# Alternatively, can check using `packageVersion("base")`.
# Using shell version string instead here for consistency.
check_version(
    name = "R",
    version = koopa_version("R"),
    version_cmd = c(
        "R --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    ),
    eval = "=="
)

# Python
check_version(
    name = "python3",
    version = switch(
        EXPR = os,
        ubuntu = "3.6",
        koopa_version("python")
    ),
    version_cmd = c(
        "python3 --version 2>&1",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# Vim
check_version(
    name = "vim",
    # Check without patches.
    # e.g. 8.1 instead of 8.1.1523.
    version = sub(
        pattern = "\\.[[:digit:]]+$",
        replacement = "",
        koopa_version("vim")
    ),
    version_cmd = c(
        "vim --version",
        "head -n 1",
        "cut -d ' ' -f 5"
    )
)

# Emacs
# Setting a hard dependency here, to allow for spacemacs.
check_version(
    name = "emacs",
    version = koopa_version("emacs"),
    version_cmd = c(
        "emacs --version",
        "head -n 1",
        "cut -d ' ' -f 3"
    )
)

# Tmux
check_version(
    name = "tmux",
    version = koopa_version("tmux"),
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
        koopa_version("git")
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
        darwin = "2.2.10",
        ubuntu = "2.2.4",
        koopa_version("gpg")
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
        koopa_version("gsl")
    ),
    version_cmd = c(
        "gsl-config --version",
        "head -n 1"
    )
)

# HDF5
# Debian: `dpkg -s libhdf5-dev`
check_version(
    name = "h5cc",
    version = major_koopa_version("hdf5"),
    version_cmd = c(
        "h5cc -showconfig",
        "grep 'HDF5 Version:'",
        "sed -E 's/^(.+): //'"
    )
)

# htop
check_version(
    name = "htop",
    version = koopa_version("htop"),
    version_cmd = c(
        "htop --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# OpenSSL
check_version(
    name = "openssl",
    version = switch(
        EXPR = os,
        rhel = "1.0.2",
        koopa_version("openssl")
    ),
    version_cmd = c(
        "openssl version",
        "head -n 1",
        "cut -d ' ' -f 2"
    )
)

# Pandoc
check_version(
    name = "pandoc",
    version = koopa_version("pandoc"),
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
    version = koopa_version("tex"),
    version_cmd = c(
        "tex --version",
        "head -n 1",
        "cut -d '(' -f 2",
        "cut -d ')' -f 1",
        "cut -d ' ' -f 3",
        "cut -d '/' -f 1"
    )
)

# OS-specific programs.
if (isTRUE(linux)) {
    # GCC
    check_version(
        name = "gcc",
        version = switch(
            EXPR = os,
            ubuntu = "7.4.0",
            koopa_version("gcc")
        ),
        version_cmd = c(
            "gcc --version",
            "head -n 1",
            "cut -d ' ' -f 3"
        ),
        eval = "=="
    )
    
    # coreutils
    # This is used for shebang. Version 8.30 marks support of `-S` flag, which
    # supports argument flags such as `--vanilla` for Rscript.
    check_version(
        name = "/usr/bin/env",
        version = koopa_version("coreutils"),
        version_cmd = c(
            "/usr/bin/env --version",
            "head -n 1",
            "cut -d ' ' -f 4"
        ),
        eval = "=="
    )
} else if (os == "darwin") {
    # Homebrew.
    installed("brew")

    # clang (Apple LLVM version).
    check_version(
        name = "clang",
        version = koopa_version("clang"),
        version_cmd = c(
            "clang --version",
            "head -n 1",
            "cut -d ' ' -f 4"
        ),
        eval = "=="
    )
    
    # GCC (Apple LLVM version).
    check_version(
        name = "gcc",
        version = koopa_version("clang"),
        version_cmd = c(
            "gcc --version 2>&1",
            "sed -n '2p'",
            "cut -d ' ' -f 4"
        ),
        eval = "=="
    )
}



# Optional =====================================================================
message("\nChecking optional programs.")

# Z shell
check_version(
    name = "zsh",
    version = koopa_version("zsh"),
    version_cmd = c(
        "zsh --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# Conda
check_version(
    name = "conda",
    version = koopa_version("conda"),
    version_cmd = c(
        "conda --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# Docker
check_version(
    name = "docker",
    version = switch(
        EXPR = os,
        darwin = "18.09.2",
        koopa_version("docker")
    ),
    version_cmd = c(
        "docker --version",
        "head -n 1",
        "cut -d ' ' -f 3",
        "cut -d ',' -f 1"
    ),
    eval = "==",
    required = FALSE
)

# Perl
# The cut match is a little tricky here:
# # This is perl 5, version 16, subversion 3 (v5.16.3)
check_version(
    name = "perl",
    version = koopa_version("perl"),
    version_cmd = c(
        "perl --version",
        "sed -n '2p'",
        "cut -d '(' -f 2 | cut -d ')' -f 1"
    ),
    eval = "==",
    required = FALSE
)

# perlbrew
check_version(
    name = "perlbrew",
    version = koopa_version("perlbrew"),
    version_cmd = c(
        "perlbrew --version",
        "head -n 1",
        "cut -d '-' -f 2",
        "cut -d '/' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# Java
check_version(
    name = "java",
    version = koopa_version("java"),
    version_cmd = c(
        "java -version 2>&1",
        "head -n 1",
        "cut -d ' ' -f 3",
        "sed -e 's/\"//g'"
    ),
    eval = "==",
    required = FALSE
)

# Ruby
check_version(
    name = "ruby",
    version = koopa_version("ruby"),
    version_cmd = c(
        "ruby --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# rbenv
check_version(
    name = "rbenv",
    version = koopa_version("rbenv"),
    version_cmd = c(
        "rbenv --version",
        "head -n 1",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# rename
# Use Perl File::Rename, not util-linux.
if (isTRUE(linux)) {
    check_version(
        name = "rename",
        version = koopa_version("rename"),
        version_cmd = c(
            "rename --version",
            "head -n 1",
            "cut -d ' ' -f 5"
        ),
        grep_string = "File::Rename",
        required = FALSE
    )
} else if (os == "darwin") {
    # Homebrew rename doesn't return version on macOS.
    installed("rename")
}

# ShellCheck
check_version(
    name = "shellcheck",
    version = koopa_version("shellcheck"),
    version_cmd = c(
        "shellcheck --version",
        "sed -n '2p'",
        "cut -d ' ' -f 2"
    ),
    eval = "==",
    required = FALSE
)

# OS-specific programs.
if (isTRUE(linux)) {
    # RStudio Server
    check_version(
        name = "rstudio-server",
        version = koopa_version("rstudio-server"),
        version_cmd = "rstudio-server version",
        eval = "==",
        required = FALSE
    )

    # Shiny Server
    check_version(
        name = "shiny-server",
        version = koopa_version("shiny-server"),
        version_cmd = c(
            "shiny-server --version",
            "head -n 1",
            "cut -d ' ' -f 3"
        ),
        eval = "==",
        required = FALSE
    )

    # bcbio
    check_version(
        name = "bcbio_nextgen.py",
        version = koopa_version("bcbio_nextgen.py"),
        version_cmd = "bcbio_nextgen.py --version",
        eval = switch(
            EXPR = host,
            azure = "==",
            ">="
        ),
        required = FALSE
    )

    # bcbio_vm.py
    installed("bcbio_vm.py", required = FALSE)
}
