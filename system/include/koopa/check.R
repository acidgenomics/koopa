#!/usr/bin/env Rscript

## Check installed program versions.
## Updated 2019-11-25.

options(
    "error" = quote(quit(status = 1L)),
    "mc.cores" = max(1L, parallel::detectCores() - 1L),
    "warning" = quote(quit(status = 1L))
)

library("methods")



## Notes =======================================================================
## Semantic versioning
## https://semver.org/
## MAJOR.MINOR.PATCH

## If you see this error, reinstall ruby, rbenv, and emacs:
## ## Ignoring commonmarker-0.17.13 because its extensions are not built.
## ## Try: gem pristine commonmarker --version 0.17.13



## Variables ===================================================================
## Need to set this to run inside R without '--vanilla' flag (for testing).
## > Sys.setenv("KOOPA_PREFIX" = "/usr/local/koopa")

koopaHome <- Sys.getenv("KOOPA_PREFIX")
stopifnot(isTRUE(nzchar(koopaHome)))

koopaEXE <- file.path(koopaHome, "bin", "koopa")
stopifnot(file.exists(koopaEXE))

host <- system2(command = koopaEXE, args = "host-id", stdout = TRUE)
os <- system2(command = koopaEXE, args = "os-string", stdout = TRUE)

## Determine if we're on Linux or not (i.e. macOS).
rOSString <- R.Version()[["os"]]
if (grepl("darwin", rOSString)) {
    linux <- FALSE
} else {
    linux <- TRUE
}

variablesFile <- file.path(
    Sys.getenv("KOOPA_PREFIX"),
    "system",
    "include",
    "variables.txt"
)
variables <- readLines(variablesFile)



## Functions ===================================================================
checkVersion <- function(
    name,
    whichName,
    current,
    expected,
    eval = c("==", ">="),
    required = TRUE
) {
    if (missing(whichName)) {
        whichName <- name
    }
    if (identical(current, character())) {
        current <- NA_character_
    }
    stopifnot(
        is.character(name) && identical(length(name), 1L),
        (is.character(whichName) && identical(length(whichName), 1L)) ||
            is.null(whichName),
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
    if (!is.null(whichName)) {
        which <- unname(Sys.which(whichName))
        if (identical(which, "")) {
            message(sprintf(
                fmt = "  %s | %s is not installed.",
                fail, name
            ))
            return(invisible(FALSE))
        }
        which <- normalizePath(which)
    } else {
        which <- NA
    }
    ## Sanitize the version for non-identical (e.g. GTE) comparisons.
    if (!identical(eval, "==")) {
        if (grepl("\\.", current)) {
            current <- sanitizeVersion(current)
            current <- package_version(current)
        }
        if (grepl("\\.", expected)) {
            expected <- sanitizeVersion(expected)
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

currentMajorVersion <- function(name) {
    x <- currentVersion(name)
    x <- majorVersion(x)
    x
}

currentMinorVersion <- function(name) {
    x <- currentVersion(name)
    x <- minorVersion(x)
    x
}

currentVersion <- function(name) {
    script <- file.path(
        Sys.getenv("KOOPA_PREFIX"),
        "system",
        "include",
        "version",
        paste0(name, ".sh")
    )
    stopifnot(isTRUE(file.exists(script)))
    tryCatch(
        expr = system2(command = script, stdout = TRUE, stderr = FALSE),
        error = function(e) {
            character()
        }
    )
}

expectedMajorVersion <- function(x) {
    x <- expectedVersion(x)
    x <- majorVersion(x)
    x
}

expectedMinorVersion <- function(x) {
    x <- expectedVersion(x)
    stopifnot(isTRUE(grepl("\\.", x)))
    x <- minorVersion(x)
    x
}

expectedVersion <- function(x) {
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

hasGNUCoreutils <- function(command = "env") {
    status <- "FAIL"
    x <- tryCatch(
        expr = system2(
            command = command,
            args = "--version",
            stdout = TRUE,
            stderr = FALSE
        ),
        error = function(e) {
            NULL
        }
    )
    if (!is.null(x)) {
        x <- head(x, n = 1L)
        x <- grepl("GNU", x)
        if (isTRUE(x)) {
            status <- "  OK"
        }
    }
    message(sprintf(
        fmt = paste0(
            "  %s | GNU Coreutils\n",
            "       |   %.69s"
        ),
        status,
        dirname(Sys.which("env"))
    ))
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

isInstalled <- function(which) {
    nzchar(Sys.which(which))
}

## e.g. vim 8
majorVersion <- function(x) {
    strsplit(x, split = "\\.")[[1L]][[1L]]
}

## e.g. vim 8.1
minorVersion <- function(x) {
    x <- strsplit(x, split = "\\.")[[1L]]
    x <- paste(x[seq_len(2L)], collapse = ".")
    x
}

## Sanitize complicated verions:
## - 2.7.15rc1 to 2.7.15
## - 1.10.0-patch1 to 1.10.0
## - 1.0.2k-fips to 1.0.2
sanitizeVersion <- function(x) {
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



## Shells ======================================================================
message("\nShells:")
checkVersion(
    name = "Bash",
    whichName = "bash",
    current = currentVersion("bash"),
    expected = expectedVersion("bash")
)
checkVersion(
    name = "ZSH",
    whichName = "zsh",
    current = currentVersion("zsh"),
    expected = expectedVersion("zsh")
)
checkVersion(
    name = "Fish",
    whichName = "fish",
    current = currentVersion("fish"),
    expected = expectedVersion("fish")
)



## Editors =====================================================================
message("\nEditors:")
checkVersion(
    name = "Emacs",
    whichName = "emacs",
    current = currentVersion("emacs"),
    expected = expectedVersion("emacs")
)
checkVersion(
    name = "Neovim",
    whichName = "nvim",
    current = currentVersion("neovim"),
    expected = expectedVersion("neovim")
)
checkVersion(
    name = "Tmux",
    whichName = "tmux",
    current = currentVersion("tmux"),
    expected = expectedVersion("tmux")
)
checkVersion(
    name = "Vim",
    whichName = "vim",
    current = currentVersion("vim"),
    expected = expectedVersion("vim")
)



## Languages ===================================================================
message("\nPrimary languages:")
checkVersion(
    name = "Python",
    whichName = "python3",
    current = currentVersion("python"),
    expected = expectedVersion("python")
)
if (isInstalled("python3")) {
    checkVersion(
        name = "Python : pip",
        whichName = "pip",
        current = currentVersion("pip"),
        expected = expectedVersion("pip")
    )
    checkVersion(
        name = "Python : pipx",
        whichName = "pipx",
        current = currentVersion("pipx"),
        expected = expectedVersion("pipx")
    )
    checkVersion(
        name = "Python : pyenv",
        whichName = "pyenv",
        current = currentVersion("pyenv"),
        expected = expectedVersion("pyenv")
    )
}
# Can use `packageVersion("base")` instead but it doesn't always return the
# correct value for RStudio Server Pro.
checkVersion(
    name = "R",
    current = currentVersion("r"),
    expected = expectedVersion("r")
)

message("\nSecondary languages:")
checkVersion(
    name = "Go",
    whichName = "go",
    current = currentMinorVersion("go"),
    expected = expectedMinorVersion("go")
)
checkVersion(
    name = "Java",
    whichName = "java",
    current = currentVersion("java"),
    expected = expectedVersion("java")
)
checkVersion(
    name = "Perl",
    whichName = "perl",
    current = currentVersion("perl"),
    expected = expectedVersion("perl")
)
if (isInstalled("perl")) {
    checkVersion(
        name = "Perl : Perlbrew",
        whichName = "perlbrew",
        current = currentVersion("perlbrew"),
        expected = expectedVersion("perlbrew")
    )
}
checkVersion(
    name = "Ruby",
    whichName = "ruby",
    current = currentVersion("ruby"),
    expected = expectedVersion("ruby")
)
if (isInstalled("ruby")) {
    checkVersion(
        name = "Ruby : rbenv",
        whichName = "rbenv",
        current = currentVersion("rbenv"),
        expected = expectedVersion("rbenv")
    )
}
checkVersion(
    name = "Rust",
    whichName = "rustc",
    current = currentVersion("rust"),
    expected = expectedVersion("rust")
)
if (isInstalled("rustc")) {
    checkVersion(
        name = "Rust : rustup",
        whichName = "rustup",
        current = currentVersion("rustup"),
        expected = expectedVersion("rustup")
    )
}



## Basic dependencies ==========================================================
message("\nBasic dependencies:")
hasGNUCoreutils()
## > installed(
## >     which = c(
## >         ## "[",
## >         "b2sum",
## >         "base32",
## >         "base64",
## >         "basename",
## >         "basenc",
## >         "cat",
## >         "chcon",
## >         "chgrp",
## >         "chmod",
## >         "chown",
## >         "chroot",
## >         "cksum",
## >         "comm",
## >         "cp",
## >         "csplit",
## >         "cut",
## >         "date",
## >         "dd",
## >         "df",
## >         "dir",
## >         "dircolors",
## >         "dirname",
## >         "du",
## >         "echo",
## >         "env",
## >         "expand",
## >         "expr",
## >         "factor",
## >         "false",
## >         "fmt",
## >         "fold",
## >         "groups",
## >         "head",
## >         "hostid",
## >         "id",
## >         "install",
## >         "join",
## >         "kill",
## >         "link",
## >         "ln",
## >         "logname",
## >         "ls",
## >         "md5sum",
## >         "mkdir",
## >         "mkfifo",
## >         "mknod",
## >         "mktemp",
## >         "mv",
## >         "nice",
## >         "nl",
## >         "nohup",
## >         "nproc",
## >         "numfmt",
## >         "od",
## >         "paste",
## >         "pathchk",
## >         "pinky",
## >         "pr",
## >         "printenv",
## >         "printf",
## >         "ptx",
## >         "pwd",
## >         "readlink",
## >         "realpath",
## >         "rm",
## >         "rmdir",
## >         "runcon",
## >         "seq",
## >         "sha1sum",
## >         "sha224sum",
## >         "sha256sum",
## >         "sha384sum",
## >         "sha512sum",
## >         "shred",
## >         "shuf",
## >         "sleep",
## >         "sort",
## >         "split",
## >         "stat",
## >         "stdbuf",
## >         "stty",
## >         "sum",
## >         "sync",
## >         "tac",
## >         "tail",
## >         "tee",
## >         "test",
## >         "timeout",
## >         "touch",
## >         "tr",
## >         "true",
## >         "truncate",
## >         "tsort",
## >         "tty",
## >         "uname",
## >         "unexpand",
## >         "uniq",
## >         "unlink",
## >         "uptime",
## >         "users",
## >         "vdir",
## >         "wc",
## >         "who",
## >         "whoami",
## >         "yes"
## >     ),
## >     required = TRUE
## > )
installed(
    which = c(
        "chsh",
        "curl",
        "grep",
        "less",
        "man",
        "parallel",
        "rename",
        "sed",
        "sh",
        "top",
        "tree",
        "wget",
        "which"
    ),
    required = TRUE
)



## Tools =======================================================================
message("\nTools:")
checkVersion(
    name = "Conda",
    whichName = "conda",
    current = currentVersion("conda"),
    expected = expectedVersion("conda")
)
checkVersion(
    name = "Git",
    whichName = "git",
    current = currentVersion("git"),
    expected = expectedVersion("git")
)
checkVersion(
    name = "GnuPG",
    whichName = "gpg",
    current = currentVersion("gpg"),
    expected = expectedVersion("gpg")
)
checkVersion(
    name = "htop",
    current = currentVersion("htop"),
    expected = expectedVersion("htop")
)
checkVersion(
    name = "Neofetch",
    whichName = "neofetch",
    current = currentVersion("neofetch"),
    expected = expectedVersion("neofetch")
)
checkVersion(
    name = "ShellCheck",
    whichName = "shellcheck",
    current = currentVersion("shellcheck"),
    expected = expectedVersion("shellcheck")
)



## Heavy dependencies ==========================================================
message("\nHeavy dependencies:")
checkVersion(
    name = "PROJ",
    whichName = "proj",
    current = currentVersion("proj"),
    expected = expectedVersion("proj")
)
checkVersion(
    name = "GDAL",
    whichName = "gdalinfo",
    current = currentVersion("gdal"),
    expected = expectedVersion("gdal")
)
checkVersion(
    name = "GSL",
    whichName = "gsl-config",
    current = currentVersion("gsl"),
    expected = expectedVersion("gsl")
)
checkVersion(
    name = "HDF5",
    whichName = "h5cc",
    current = currentVersion("hdf5"),
    expected = expectedVersion("hdf5")
)
checkVersion(
    name = "LLVM",
    ## > whichName = "llvm-config",
    whichName = NULL,
    current = currentMajorVersion("llvm"),
    expected = expectedMajorVersion("llvm")
)

## Note that macOS switched to LibreSSL in 2018.
## > checkVersion(
## >     name = "OpenSSL",
## >     whichName = "openssl",
## >     current = currentVersion("openssl"),
## >     expected = expectedVersion("openssl")
## > )
## > checkVersion(
## >     name = "Pandoc",
## >     whichName = "pandoc",
## >     current = currentVersion("pandoc"),
## >     expected = expectedVersion("pandoc")
## > )
## > checkVersion(
## >     name = "TeX Live",
## >     whichName = "tex",
## >     current = currentVersion("tex"),
## >     expected = expectedVersion("tex")
## > )

installed(
    which = c(
        "openssl",
        "pandoc",
        "pandoc-citeproc",
        "tex"
    ),
    required = TRUE
)



## OS-specific =================================================================
if (isTRUE(linux)) {
    message("\nLinux specific:")
    ## https://gcc.gnu.org/releases.html
    checkVersion(
        name = "GCC",
        whichName = "gcc",
        current = currentVersion("gcc"),
        expected = switch(
            EXPR = os,
            `amzn-2` = "7.3.1",
            `rhel-7` = "4.8.5",
            `rhel-8` = "8.2.1",
            `ubuntu-18` = "7.4.0",
            NULL
        )
    )
    checkVersion(
        name = "RStudio Server",
        whichName = "rstudio-server",
        current = currentVersion("rstudio-server"),
        expected = expectedVersion("rstudio-server")
    )
    ## This is used for shebang. Version 8.30 marks support of `-S` flag.
    ## > checkVersion(
    ## >     name = "env (coreutils)",
    ## >     whichName = "env",
    ## >     current = currentVersion("env"),
    ## >     expected = expectedVersion("coreutils")
    ## > )
    ## > checkVersion(
    ## >     name = "rename (Perl File::Rename)",
    ## >     whichName = "rename",
    ## >     current = currentVersion("perl-file-rename"),
    ## >     expected = expectedVersion("perl-file-rename")
    ## > )
} else if (identical(os, "darwin")) {
    message("\nmacOS specific:")
    checkVersion(
        name = "Homebrew",
        whichName = "brew",
        current = currentVersion("homebrew"),
        expected = expectedVersion("homebrew")
    )
    ## Apple LLVM version.
    checkVersion(
        name = "Clang",
        whichName = "clang",
        current = currentVersion("clang"),
        expected = expectedVersion("clang")
    )
    ## Apple LLVM version.
    checkVersion(
        name = "GCC",
        whichName = "gcc",
        current = currentVersion("gcc-darwin"),
        expected = expectedVersion("clang")
    )



}



## High performance ============================================================
if (
    isTRUE(linux) &&
    isTRUE(getOption("mc.cores") >= 7L)
) {
    message("\nHigh performance (HPC/VM):")
    checkVersion(
        name = "Docker",
        whichName = "docker",
        current = currentVersion("docker"),
        expected = expectedVersion("docker")
    )
    checkVersion(
        name = "Shiny Server",
        whichName = "shiny-server",
        current = currentVersion("shiny-server"),
        expected = expectedVersion("shiny-server")
    )
    checkVersion(
        name = "bcbio-nextgen",
        whichName = "bcbio_nextgen.py",
        current = currentVersion("bcbio-nextgen"),
        expected = expectedVersion("bcbio-nextgen"),
        required = FALSE
    )
    ## > installed("bcbio_vm.py", required = FALSE)
    ## > checkVersion(
    ## >     name = "bcl2fastq",
    ## >     current = currentVersion("bcl2fastq"),
    ## >     expected = expectedVersion("bcl2fastq")
    ## > )
    checkVersion(
        name = "Lmod",
        whichName = NULL,
        current = currentVersion("lmod"),
        expected = expectedVersion("lmod"),
        required = FALSE
    )
    checkVersion(
        name = "Lua",
        whichName = "lua",
        current = currentVersion("lua"),
        expected = expectedVersion("lua"),
        required = FALSE
    )
    checkVersion(
        name = "LuaRocks",
        whichName = "luarocks",
        current = currentVersion("luarocks"),
        expected = expectedVersion("luarocks"),
        required = FALSE
    )
    checkVersion(
        name = "Singularity",
        whichName = "singularity",
        current = currentVersion("singularity"),
        expected = expectedVersion("singularity"),
        required = FALSE
    )
}
