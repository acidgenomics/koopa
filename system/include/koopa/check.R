#!/usr/bin/env Rscript

## """
## Check installed program versions.
## Updated 2020-02-28.
##
## Need to set this to run inside R without '--vanilla' flag (for testing).
## > Sys.setenv("KOOPA_PREFIX" = "/usr/local/koopa")
##
## If you see this error, reinstall ruby, rbenv, and emacs:
## # Ignoring commonmarker-0.17.13 because its extensions are not built.
## # Try: gem pristine commonmarker --version 0.17.13
## """

koopaPrefix <- Sys.getenv("KOOPA_PREFIX")
stopifnot(isTRUE(nzchar(koopaPrefix)))
source(file.path(koopaPrefix, "lang", "r", "include", "header.R"))

h1("Checking koopa installation")

macos <- isMacOS()
linux <- !macos

host <- shell(command = koopa, args = "host-id", stdout = TRUE)
os <- shell(command = koopa, args = "os-string", stdout = TRUE)

docker <- isDocker()
extra <- if (Sys.getenv("KOOPA_EXTRA") == 1L) TRUE else FALSE

## Basic dependencies ==========================================================
h2("Basic dependencies")
installed(
    which = c(
        ## "[",
        ## "basenc",
        ## "chsh",  # lchsh on Fedora
        ## "rename",
        ## "top",
        ## "uptime",
        "b2sum",
        "base32",
        "base64",
        "basename",
        "bc",
        "cat",
        "chcon",
        "chgrp",
        "chmod",
        "chown",
        "chroot",
        "cksum",
        "comm",
        "cp",
        "csplit",
        "curl",
        "cut",
        "date",
        "dd",
        "df",
        "dir",
        "dircolors",
        "dirname",
        "du",
        "echo",
        "env",
        "expand",
        "expr",
        "factor",
        "false",
        "find",
        "fmt",
        "fold",
        "g++",
        "gcc",
        "grep",
        "groups",
        "head",
        "hostid",
        "id",
        "install",
        "join",
        "kill",
        "less",
        "link",
        "ln",
        "logname",
        "ls",
        "man",
        "md5sum",
        "mkdir",
        "mkfifo",
        "mknod",
        "mktemp",
        "mv",
        "nice",
        "nl",
        "nohup",
        "nproc",
        "numfmt",
        "od",
        "openssl",
        "parallel",
        "paste",
        "patch",
        "pathchk",
        "pinky",
        "pr",
        "printenv",
        "printf",
        "ptx",
        "pwd",
        "readlink",
        "realpath",
        "rm",
        "rmdir",
        "runcon",
        "sed",
        "seq",
        "sh",
        "sha1sum",
        "sha224sum",
        "sha256sum",
        "sha384sum",
        "sha512sum",
        "shred",
        "shuf",
        "sleep",
        "sort",
        "split",
        "stat",
        "stdbuf",
        "stty",
        "sum",
        "sync",
        "tac",
        "tail",
        "tee",
        "test",
        "timeout",
        "touch",
        "tr",
        "tree",
        "true",
        "truncate",
        "tsort",
        "tty",
        "udunits2",
        "uname",
        "unexpand",
        "uniq",
        "unlink",
        "users",
        "vdir",
        "wc",
        "wget",
        "which",
        "who",
        "whoami",
        "xargs",
        "yes"
    ),
    path = FALSE
)

## Shells ======================================================================
h2("Shells")
checkVersion(
    name = "Bash",
    whichName = "bash",
    current = currentVersion("bash"),
    expected = expectedVersion("bash")
)
checkVersion(
    name = "Zsh",
    whichName = "zsh",
    current = currentVersion("zsh"),
    expected = expectedVersion("zsh")
)
if (!isTRUE(docker)) {
    checkVersion(
        name = "Fish",
        whichName = "fish",
        current = currentVersion("fish"),
        expected = expectedVersion("fish")
    )
}

## Core packages ===============================================================
h2("Core packages")
checkVersion(
    name = "GNU autoconf",
    whichName = "autoconf",
    current = currentVersion("autoconf"),
    expected = expectedVersion("autoconf")
)
checkVersion(
    name = "GNU automake",
    whichName = "automake",
    current = currentVersion("automake"),
    expected = expectedVersion("automake")
)
if (isTRUE(linux)) {
    checkVersion(
        name = "GNU binutils",
        whichName = "ld",
        current = currentVersion("binutils"),
        expected = expectedVersion("binutils")
    )
}
checkVersion(
    name = "GNU coreutils",
    whichName = "env",
    current = currentVersion("coreutils"),
    expected = expectedVersion("coreutils")
)
checkVersion(
    name = "GNU findutils",
    whichName = "find",
    current = currentVersion("findutils"),
    expected = expectedVersion("findutils")
)
checkVersion(
    name = "GNU gawk",
    whichName = "gawk",
    current = currentVersion("gawk"),
    expected = expectedVersion("gawk")
)
checkVersion(
    name = "GNU gcc",
    whichName = "gcc",
    current = currentMajorVersion("gcc"),
    expected = expectedMajorVersion("gcc")
)
checkVersion(
    name = "GNU grep",
    whichName = "grep",
    current = currentVersion("grep"),
    expected = expectedVersion("grep")
)
if (isTRUE(linux)) {
    checkVersion(
        name = "GNU libtool",
        whichName = "libtool",
        current = currentVersion("libtool"),
        expected = expectedVersion("libtool")
    )
}
checkVersion(
    name = "GNU make",
    whichName = "make",
    current = currentVersion("make"),
    expected = expectedVersion("make")
)
if (isTRUE(linux)) {
    checkVersion(
        name = "GNU ncurses",
        whichName = "ncurses6-config",
        current = currentMinorVersion("ncurses"),
        expected = expectedVersion("ncurses")
    )
}
checkVersion(
    name = "GNU parallel",
    whichName = "parallel",
    current = currentVersion("parallel"),
    expected = expectedVersion("parallel")
)
checkVersion(
    name = "GNU patch",
    whichName = "patch",
    current = currentVersion("patch"),
    expected = expectedVersion("patch")
)
checkVersion(
    name = "GNU texinfo",
    whichName = "makeinfo",
    current = currentVersion("texinfo"),
    expected = expectedVersion("texinfo")
)
checkVersion(
    name = "CMake",
    whichName = "cmake",
    current = currentVersion("cmake"),
    expected = expectedVersion("cmake")
)

## Editors =====================================================================
h2("Editors")
if (!isTRUE(docker)) {
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
}
checkVersion(
    name = "Tmux",
    whichName = "tmux",
    current = currentVersion("tmux"),
    expected = expectedVersion("tmux")
)
checkVersion(
    name = "Vim",
    whichName = "vim",
    current = currentMinorVersion("vim"),
    expected = expectedMinorVersion("vim")
)

## Languages ===================================================================
h2("Primary languages")
checkVersion(
    name = "Python",
    whichName = "python3",
    current = currentVersion("python"),
    expected = expectedVersion("python")
)
if (isCellar("R")) {
    checkVersion(
        name = "R",
        current = currentVersion("r"),
        expected = expectedVersion("r")
    )
} else {
    installed("R")
}

h2("Secondary languages")
if (!isTRUE(docker)) {
    checkVersion(
        name = "Go",
        whichName = "go",
        current = currentMinorVersion("go"),
        expected = expectedMinorVersion("go")
    )
}
checkVersion(
    name = "Java",
    whichName = "java",
    current = currentVersion("java"),
    expected = expectedVersion("java")
)
if (!isTRUE(docker)) {
    checkVersion(
        name = "Julia",
        whichName = "julia",
        current = currentVersion("julia"),
        expected = expectedVersion("julia")
    )
}
checkVersion(
    name = "Perl",
    whichName = "perl",
    current = currentMinorVersion("perl"),
    expected = expectedMinorVersion("perl")
)
if (!isTRUE(docker)) {
    checkVersion(
        name = "Ruby",
        whichName = "ruby",
        current = currentVersion("ruby"),
        expected = expectedVersion("ruby")
    )
    checkVersion(
        name = "Rust",
        whichName = "rustc",
        current = currentVersion("rust"),
        expected = expectedVersion("rust")
    )
}

## Version managers ============================================================
h2("Version managers")
## This isn't returning true currently for Bioconductor builds.
checkVersion(
    name = "Conda",
    whichName = "conda",
    current = currentVersion("conda"),
    expected = expectedVersion("conda"),
    required = FALSE
)
if (!isTRUE(docker)) {
    checkVersion(
        name = "Perl : Perlbrew",
        whichName = "perlbrew",
        current = currentVersion("perlbrew"),
        expected = expectedVersion("perlbrew")
    )
}
checkVersion(
    name = "Python : pip",
    whichName = "pip3",
    current = currentVersion("pip"),
    expected = expectedVersion("pip")
)
checkVersion(
    name = "Python : pipx",
    whichName = "pipx",
    current = currentVersion("pipx"),
    expected = expectedVersion("pipx")
)
if (!isTRUE(docker)) {
    checkVersion(
        name = "Python : pyenv",
        whichName = "pyenv",
        current = currentVersion("pyenv"),
        expected = expectedVersion("pyenv")
    )
    checkVersion(
        name = "Ruby : rbenv",
        whichName = "rbenv",
        current = currentVersion("rbenv"),
        expected = expectedVersion("rbenv")
    )
    checkVersion(
        name = "Rust : cargo",
        whichName = "cargo",
        current = currentVersion("cargo"),
        expected = expectedVersion("cargo")
    )
    checkVersion(
        name = "Rust : rustup",
        whichName = "rustup",
        current = currentVersion("rustup"),
        expected = expectedVersion("rustup")
    )
}

## Cloud APIs ==================================================================
if (
    !identical(os, "arch-rolling") &&
    !identical(os, "opensuse-leap-15")
) {
    h2("Cloud APIs")
    checkVersion(
        name = "Amazon Web Services (AWS) CLI",
        whichName = "aws",
        current = currentMinorVersion("aws-cli"),
        expected = expectedMinorVersion("aws-cli")
    )
    checkVersion(
        name = "Microsoft Azure CLI",
        whichName = "az",
        current = currentVersion("azure-cli"),
        expected = expectedVersion("azure-cli")
    )
    checkVersion(
        name = "Google Cloud SDK",
        whichName = "gcloud",
        current = currentVersion("google-cloud-sdk"),
        expected = expectedVersion("google-cloud-sdk")
    )
}

## Tools =======================================================================
h2("Tools")
checkVersion(
    name = "Git",
    whichName = "git",
    current = currentVersion("git"),
    expected = expectedVersion("git")
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

## Shell tools =================================================================
h2("Shell tools")
if (!isTRUE(docker)) {
    checkVersion(
        name = "The Silver Searcher (Ag)",
        whichName = "ag",
        current = currentVersion("the-silver-searcher"),
        expected = expectedVersion("the-silver-searcher")
    )
    checkVersion(
        name = "exa",
        whichName = "exa",
        current = currentVersion("exa"),
        expected = expectedVersion("exa")
    )
    checkVersion(
        name = "fd",
        whichName = "fd",
        current = currentVersion("fd"),
        expected = expectedVersion("fd")
    )
    checkVersion(
        name = "ripgrep",
        whichName = "rg",
        current = currentVersion("ripgrep"),
        expected = expectedVersion("ripgrep")
    )
    if (isTRUE(extra)) {
        checkVersion(
            name = "autojump",
            whichName = "autojump",
            current = currentVersion("autojump"),
            expected = expectedVersion("autojump")
        )
        ## This updates frequently, so be less strict about check.
        checkVersion(
            name = "broot",
            whichName = "broot",
            current = currentMinorVersion("broot"),
            expected = expectedMinorVersion("broot")
        )
        checkVersion(
            name = "fzf",
            whichName = "fzf",
            current = currentVersion("fzf"),
            expected = expectedVersion("fzf")
        )
    }
}
checkVersion(
    name = "ShellCheck",
    whichName = "shellcheck",
    current = currentVersion("shellcheck"),
    expected = expectedVersion("shellcheck")
)
installed("shunit2")

## Heavy dependencies ==========================================================
if (!isTRUE(docker)) {
    h2("Heavy dependencies")
    if (isTRUE(linux)) {
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
    } else {
        installed(c("proj", "gdalinfo"))
    }
    checkVersion(
        name = "GEOS",
        whichName = "geos-config",
        current = currentVersion("geos"),
        expected = expectedVersion("geos")
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
        whichName = NA,
        current = currentMajorVersion("llvm"),
        expected = switch(
            EXPR = os,
            `rhel-7` = "7",
            expectedMajorVersion("llvm")
        )
    )
    checkVersion(
        name = "SQLite",
        whichName = "sqlite3",
        current = currentVersion("sqlite"),
        expected = switch(
            EXPR = os,
            `macos-10.14` = "3.24.0",
            `macos-10.15` = "3.28.0",
            expectedVersion("sqlite")
        )
    )
    installed(
        which = c(
            "pandoc",
            "pandoc-citeproc",
            "tex"
        )
    )
}

## OS-specific =================================================================
if (isTRUE(linux)) {
    h2("Linux specific")
    checkVersion(
        name = "GnuPG",
        whichName = "gpg",
        current = currentVersion("gnupg"),
        expected = expectedVersion("gpg")
    )
    checkVersion(
        name = "pass",
        current = currentVersion("pass"),
        expected = expectedVersion("pass")
    )
    if (!isTRUE(docker)) {
        checkVersion(
            name = "RStudio Server",
            whichName = "rstudio-server",
            current = currentVersion("rstudio-server"),
            expected = expectedVersion("rstudio-server")
        )
        checkVersion(
            name = "docker-credential-pass",
            current = currentVersion("docker-credential-pass"),
            expected = expectedVersion("docker-credential-pass")
        )
        checkVersion(
            name = "rename (Perl File::Rename)",
            whichName = "rename",
            current = currentVersion("perl-file-rename"),
            expected = expectedVersion("perl-file-rename")
        )
    }
} else if (isTRUE(macos)) {
    h2("macOS specific")
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
        current = currentVersion("gcc"),
        expected = expectedVersion("clang")
    )
    checkMacOSAppVersion(c(
        ## "Numbers",
        "Alacritty",
        "Aspera Connect",
        "BBEdit",
        "BibDesk",
        "Docker",
        "LibreOffice",
        "Microsoft Excel",
        "RStudio",
        "Tunnelblick",
        "Visual Studio Code",
        "Xcode",
        "iTerm"
    ))
    checkHomebrewCaskVersion("gpg-suite")
}

## High performance ============================================================
if (
    isTRUE(linux) &&
    isTRUE(getOption("mc.cores") >= 3L) &&
    !isTRUE(docker)
) {
    h2("High performance")
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
        expected = expectedVersion("bcbio-nextgen")
    )
    ## > installed("bcbio_vm.py", required = FALSE)
    ## > checkVersion(
    ## >     name = "bcl2fastq",
    ## >     current = currentVersion("bcl2fastq"),
    ## >     expected = expectedVersion("bcl2fastq"),
    ## >     required = FALSE
    ## > )
    checkVersion(
        name = "Lmod",
        whichName = NA,
        current = currentVersion("lmod"),
        expected = expectedVersion("lmod")
    )
    checkVersion(
        name = "Lua",
        whichName = "lua",
        current = currentVersion("lua"),
        expected = expectedVersion("lua")
    )
    checkVersion(
        name = "LuaRocks",
        whichName = "luarocks",
        current = currentVersion("luarocks"),
        expected = expectedVersion("luarocks")
    )
    # > checkVersion(
    # >     name = "Singularity",
    # >     whichName = "singularity",
    # >     current = currentVersion("singularity"),
    # >     expected = expectedVersion("singularity")
    # > )
}

## Python packages =============================================================
h2("Python packages")
installed(
    which = c(
        "black",
        "flake8",
        "pylint",
        "pytest"
    )
)

if (Sys.getenv("KOOPA_CHECK_FAIL") == 1L) {
    stop("System failed checks.")
}
