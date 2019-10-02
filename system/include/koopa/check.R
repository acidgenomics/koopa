#!/usr/bin/env Rscript

## Check installed program versions.
## Updated 2019-10-02.

options(
    error = quote(quit(status = 1L)),
    warning = quote(quit(status = 1L))
)

## FIXME Add Rust compiler check.



## Notes =======================================================================
## If you see this error, reinstall ruby, rbenv, and emacs:
## ## Ignoring commonmarker-0.17.13 because its extensions are not built.
## ## Try: gem pristine commonmarker --version 0.17.13



## Koopa config =================================================================
koopa_home <- Sys.getenv("KOOPA_HOME")
## > koopa_home <- Sys.setenv("KOOPA_HOME" = "/usr/local/koopa")
stopifnot(isTRUE(nzchar(koopa_home)))

koopa_exe <- file.path(koopa_home, "bin", "koopa")
stopifnot(file.exists(koopa_exe))

host <- system2(command = koopa_exe, args = "host-type", stdout = TRUE)
os <- system2(command = koopa_exe, args = "os-type", stdout = TRUE)

## Determine if we're on Linux or not (i.e. macOS).
r_os_string <- R.Version()[["os"]]
if (grepl("darwin", r_os_string)) {
    linux <- FALSE
} else {
    linux <- TRUE
}



## Version parsers =============================================================
variables_file <- file.path(
    Sys.getenv("KOOPA_HOME"),
    "system",
    "include",
    "variables.txt"
)
variables <- readLines(variables_file)

expected_version <- function(x) {
    keep <- grepl(pattern = paste0("^", x, "="), x = variables)
    stopifnot(sum(keep, na.rm = TRUE) == 1L)
    x <- variables[keep]
    stopifnot(isTRUE(nzchar(x)))
    x <- sub(
        pattern = "^(.+)=\"(.+)\"$",
        replacement = "\\2",
        x = x
    )
    x
}

expected_major_version <- function(x) {
    x <- expected_version(x)
    stopifnot(isTRUE(grepl("\\.", x)))
    x <- gsub("^(.+)\\.(.+)\\.(.+)$", "\\1.\\2", x)
    x
}

current_version <- function(name) {
    script <- file.path(
        Sys.getenv("KOOPA_HOME"),
        "system",
        "include",
        "version",
        paste0(name, ".sh")
    )
    if (!file.exists(script)) return(NULL)
    tryCatch(
        expr = system2(command = script, stdout = TRUE, stderr = FALSE),
        error = function(e) {
            NULL
        }
    )
}

## Sanitize complicated verions:
## - 2.7.15rc1 to 2.7.15
## - 1.10.0-patch1 to 1.10.0
## - 1.0.2k-fips to 1.0.2
sanitize_version <- function(x) {
    ## Strip trailing "+" (e.g. "Python 2.7.15+").
    x <- sub("\\+$", "", x)
    ## Strip quotes (e.g. `java -version` returns '"12.0.1"').
    x <- gsub("\"", "", x)
    ## Strip hyphenated terminator.(e.g. `java -version` returns "1.8.0_212").
    x <- sub("(-|_).+$", "", x)
    x <- sub("\\.([0-9]+)[-a-z]+[0-9]+?$", ".\\1", x)
    ## Strip leading letter.
    x <- sub("^[a-z]+", "", x)
    ## Strip trailing letter.
    x <- sub("[a-z]+$", "", x)
    x
}

check_version <- function(
    name,
    which_name,
    current,
    expected,
    eval = c("==", ">="),
    required = TRUE
) {
    if (missing(which_name)) {
        which_name <- name
    }
    stopifnot(
        is.character(name) && identical(length(name), 1L),
        (is.character(which_name) && identical(length(which_name), 1L)) ||
            is.null(which_name),
        is(current, "package_version") ||
            (is.character(current) && identical(length(current), 1L)) ||
            is.null(current),
        is(expected, "package_version") ||
            (is.character(expected) && identical(length(expected), 1L)),
        is.logical(required) && identical(length(required), 1L)
    )
    eval <- match.arg(eval)
    if (isTRUE(required)) {
        fail <- "FAIL"
    } else {
        fail <- "NOTE"
    }
    ## Check to see if program is installed.
    if (!is.null(which_name)) {
        which <- unname(Sys.which(which_name))
        if (identical(which, "")) {
            message(sprintf(
                fmt = "  %s | %s is not installed.",
                fail, name
            ))
            return(invisible(FALSE))
        }
        which <- normalizePath(which)
    } else {
        which <- NA_character_
    }
    ## Sanitize the version for non-identical (e.g. GTE) comparisons.
    if (!identical(eval, "==")) {
        if (grepl("\\.", current)) {
            current <- sanitize_version(current)
            current <- package_version(current)
        }
        if (grepl("\\.", expected)) {
            expected <- sanitize_version(expected)
            expected <- package_version(expected)
        }
    }
    ## Compare current to expected version.
    if (eval == ">=") {
        ok <- current >= expected
    } else if (eval == "==") {
        ok <- current == expected
    }
    if (isTRUE(ok)) {
        status <- "  OK"
    } else {
        status <- fail
    }
    message(
        sprintf(
            fmt = paste0(
                "  %s | %s (%s %s %s)\n",
                "       |   %.69s"
            ),
            status, name,
            current, eval, expected,
            which
        )
    )
    invisible(ok)
}

installed <- function(which, required = TRUE) {
    stopifnot(
        is.character(which) && length(which) >= 1L,
        is.logical(required) && length(required) == 1L
    )
    if (isTRUE(required)) {
        fail <- "FAIL"
    } else {
        fail <- "NOTE"
    }
    invisible(vapply(
        X = which,
        FUN = function(which) {
            ok <- nzchar(Sys.which(which))
            if (!isTRUE(ok)) {
                message(sprintf(
                    fmt = "  %s | %s missing.",
                    fail, which
                ))
            } else {
                message(sprintf(
                    fmt = paste0(
                        "    OK | %s\n",
                        "       |   %.69s"
                    ),
                    which, Sys.which(which)
                ))
            }
            invisible(ok)
        },
        FUN.VALUE = logical(1L)
    ))
}



## All platforms ===============================================================
check_version(
    name = "Bash",
    which_name = "bash",
    current = current_version("bash"),
    expected = expected_version("bash")
)
check_version(
    name = "ZSH",
    which_name = "zsh",
    current = current_version("zsh"),
    expected = expected_version("zsh")
)
## Alternatively, can return current here using `packageVersion("base")`.
check_version(
    name = "R",
    current = current_version("r"),
    expected = expected_version("r")
)
check_version(
    name = "Python",
    which_name = "python3",
    current = current_version("python"),
    expected = expected_version("python")
)
check_version(
    name = "Vim",
    which_name = "vim",
    current = current_version("vim"),
    expected = expected_version("vim")
)
check_version(
    name = "Neovim",
    which_name = "nvim",
    current = current_version("neovim"),
    expected = expected_version("neovim")
)
check_version(
    name = "Emacs",
    which_name = "emacs",
    current = current_version("emacs"),
    expected = expected_version("emacs")
)
check_version(
    name = "Tmux",
    which_name = "tmux",
    current = current_version("tmux"),
    expected = expected_version("tmux")
)
check_version(
    name = "htop",
    current = current_version("htop"),
    expected = expected_version("htop")
)
check_version(
    name = "Neofetch",
    which_name = "neofetch",
    current = current_version("neofetch"),
    expected = expected_version("neofetch")
)
check_version(
    name = "Git",
    which_name = "git",
    current = current_version("git"),
    expected = expected_version("git")
)
check_version(
    name = "GnuPG",
    which_name = "gpg",
    current = current_version("gpg"),
    expected = expected_version("gpg")
)
check_version(
    name = "OpenSSL",
    which_name = "openssl",
    current = current_version("openssl"),
    expected = switch(
        EXPR = os,
        ## Note that macOS switched to LibreSSL in 2018.
        darwin = "2.6.5",
        rhel7 = "1.0.2k",
        expected_version("openssl")
    )
)
check_version(
    name = "Pandoc",
    which_name = "pandoc",
    current = current_version("pandoc"),
    expected = switch(
        EXPR = os,
        rhel7 = "1.12.3.1",
        expected_version("pandoc")
    )
)
check_version(
    name = "TeX Live",
    which_name = "tex",
    current = current_version("tex"),
    expected = switch(
        EXPR = os,
        rhel7 = "2013",
        ubuntu = "2017",
        expected_version("tex")
    )
)
check_version(
    name = "GSL",
    which_name = "gsl-config",
    current = current_version("gsl"),
    expected = expected_version("gsl")
)
check_version(
    name = "HDF5",
    which_name = "h5cc",
    current = current_version("hdf5"),
    expected = expected_version("hdf5")
)
check_version(
    name = "Conda",
    which_name = "conda",
    current = current_version("conda"),
    expected = expected_version("conda")
)
check_version(
    name = "Docker",
    which_name = "docker",
    current = current_version("docker"),
    expected = switch(
        EXPR = os,
        darwin = "18.09.2",
        expected_version("docker")
    )
)
check_version(
    name = "Perlbrew",
    which_name = "perlbrew",
    current = current_version("perlbrew"),
    expected = expected_version("perlbrew")
)
check_version(
    name = "Perl",
    which_name = "perl",
    current = current_version("perl"),
    expected = expected_version("perl")
)
check_version(
    name = "Java",
    which_name = "java",
    current = current_version("java"),
    expected = expected_version("java")
)
check_version(
    name = "rbenv",
    current = current_version("rbenv"),
    expected = expected_version("rbenv")
)
check_version(
    name = "Ruby",
    which_name = "ruby",
    current = current_version("ruby"),
    expected = expected_version("ruby")
)
check_version(
    name = "PROJ",
    which_name = "proj",
    current = current_version("proj"),
    expected = expected_version("proj")
)
check_version(
    name = "GDAL",
    which_name = "gdalinfo",
    current = current_version("gdal"),
    expected = switch(
        EXPR = os,
        darwin = "2.4.2",
        expected_version("gdal")
    )
)
check_version(
    name = "ShellCheck",
    which_name = "shellcheck",
    current = current_version("shellcheck"),
    expected = expected_version("shellcheck")
)
## This is used for shebang. Version 8.30 marks support of `-S` flag.
check_version(
    name = "env (coreutils)",
    which_name = "env",
    current = current_version("env"),
    expected = expected_version("coreutils")
)



## OS-specific =================================================================
if (isTRUE(linux)) {
    message("\nLinux specific:")
    check_version(
        name = "GCC",
        which_name = "gcc",
        current = current_version("gcc"),
        expected = switch(
            EXPR = os,
            rhel7 = "4.8.5",
            rhel8 = "8.2.1",
            ubuntu = "7.4.0"
        )
    )
    check_version(
        name = "rename (Perl File::Rename)",
        which_name = "rename",
        current = current_version("perl-file-rename"),
        expected = expected_version("perl-file-rename")
    )
    check_version(
        name = "RStudio Server",
        which_name = "rstudio-server",
        current = current_version("rstudio-server"),
        expected = expected_version("rstudio-server")
    )
    check_version(
        name = "Shiny Server",
        which_name = "shiny-server",
        current = current_version("shiny-server"),
        expected = expected_version("shiny-server")
    )
    check_version(
        name = "bcbio-nextgen",
        which_name = "bcbio_nextgen.py",
        # FIXME Improve name consistency
        current = current_version("bcbio-nextgen"),
        expected = expected_version("bcbio-nextgen"),
        required = FALSE
    )
    installed("bcbio_vm.py", required = FALSE)
} else if (os == "darwin") {
    message("\nmacOS specific:")
    check_version(
        name = "Homebrew",
        which_name = "brew",
        current = current_version("homebrew"),
        expected = expected_version("homebrew")
    )
    ## Apple LLVM version.
    check_version(
        name = "Clang",
        which_name = "clang",
        current = current_version("clang"),
        expected = expected_version("clang")
    )
    ## Apple LLVM version.
    check_version(
        name = "GCC",
        which_name = "gcc",
        current = current_version("gcc-darwin"),
        expected = expected_version("clang")
    )
}



## Base dependencies ===========================================================
message("\nBase dependencies:")
installed(
    which = c(
        "basename",
        "bash",
        "cat",
        "chsh",
        "curl",
        "dirname",
        "echo",
        "env",
        "grep",
        "head",
        "less",
        "man",
        "nice",
        "parallel",
        "realpath",
        "rename",
        "sed",
        "sh",
        "tail",
        "tee",
        "top",
        "wget",
        "which"
    ),
    required = TRUE
)
