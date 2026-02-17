"""Application locator functions.

Converted from 240 Bash locate-*.sh functions. Each wraps locate_app() with
specific app-name and bin-name arguments.
"""

from __future__ import annotations

import os
import shutil
from collections.abc import Callable

from . import prefix as pfx


def locate_app(
    app_name: str,
    bin_name: str | None = None,
    *,
    allow_bootstrap: bool = False,
    allow_koopa_bin: bool = True,
    allow_missing: bool = False,
    allow_opt_bin: bool = True,
    allow_system: bool = False,
    only_bootstrap: bool = False,
    only_system: bool = False,
) -> str:
    """Locate file system path to an application.

    App locator prioritization:
    1. Check for linked program in koopa bin.
    2. Check for linked program in koopa opt.
    3. Check for linked program in bootstrap.
    4. Check system PATH.
    """
    if bin_name is None:
        bin_name = app_name
    if only_system:
        path = _which_system(bin_name)
        if path:
            return path
        if allow_missing:
            return ""
        msg = f"Failed to locate system '{bin_name}'."
        raise FileNotFoundError(msg)
    # 1. koopa bin
    if allow_koopa_bin:
        try:
            bin_dir = pfx.bin_prefix()
        except Exception:
            bin_dir = ""
        if bin_dir:
            candidate = os.path.join(bin_dir, bin_name)
            if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                return candidate
    # 2. koopa opt
    if allow_opt_bin:
        try:
            opt = pfx.opt_prefix()
        except Exception:
            opt = ""
        if opt:
            candidate = os.path.join(opt, app_name, "bin", bin_name)
            if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                return candidate
    # 3. bootstrap
    if allow_bootstrap or only_bootstrap:
        try:
            bp = pfx.bootstrap_prefix()
        except Exception:
            bp = ""
        if bp:
            candidate = os.path.join(bp, "bin", bin_name)
            if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                return candidate
        if only_bootstrap:
            if allow_missing:
                return ""
            msg = f"Failed to locate bootstrap '{bin_name}'."
            raise FileNotFoundError(msg)
    # 4. system PATH
    if allow_system:
        path = _which_system(bin_name)
        if path:
            return path
    if allow_missing:
        return ""
    msg = f"Failed to locate '{bin_name}'."
    raise FileNotFoundError(msg)


def _which_system(name: str) -> str:
    """Locate a system command, skipping koopa paths."""
    result = shutil.which(name)
    return result if result else ""


def _make_locator(
    app_name: str,
    bin_name: str | None = None,
    *,
    allow_system: bool = False,
    only_system: bool = False,
    allow_bootstrap: bool = False,
    only_bootstrap: bool = False,
) -> Callable[..., str]:
    """Factory to create a locator function for a specific app."""
    if bin_name is None:
        bin_name = app_name

    def locator(**kwargs: bool) -> str:
        kw = {
            "allow_system": allow_system,
            "only_system": only_system,
            "allow_bootstrap": allow_bootstrap,
            "only_bootstrap": only_bootstrap,
        }
        kw.update(kwargs)
        return locate_app(app_name, bin_name, **kw)

    locator.__name__ = f"locate_{app_name.replace('-', '_')}"
    locator.__doc__ = f"Locate {app_name}."
    return locator


# System tools (only_system=True for coreutils and standard tools)
_SYSTEM_TOOLS = (
    "basename",
    "cat",
    "chmod",
    "chgrp",
    "chown",
    "cp",
    "cut",
    "date",
    "df",
    "dirname",
    "du",
    "echo",
    "env",
    "groups",
    "gunzip",
    "gzip",
    "head",
    "hostname",
    "id",
    "install",
    "less",
    "ln",
    "locale",
    "ls",
    "mkdir",
    "mktemp",
    "mv",
    "newgrp",
    "od",
    "open",
    "paste",
    "passwd",
    "patch",
    "readlink",
    "realpath",
    "rm",
    "sed",
    "sh",
    "sort",
    "stat",
    "strip",
    "sudo",
    "tac",
    "tail",
    "tar",
    "tee",
    "touch",
    "tr",
    "uname",
    "uniq",
    "wc",
    "whoami",
    "xargs",
    "yes",
)

# Koopa-managed apps (default: search koopa bin → opt → system PATH)
_KOOPA_APPS = (
    "7z",
    "ar",
    "ascp",
    "aspell",
    "autoreconf",
    "autoupdate",
    "awk",
    "aws",
    "bash",
    "bc",
    "bedtools",
    "bowtie2",
    "bowtie2-build",
    "brew",
    "brotli",
    "bundle",
    "bunzip2",
    "bzip2",
    "cabal",
    "cargo",
    "chezmoi",
    "clang",
    "cmake",
    "compress",
    "conda",
    "convmv",
    "corepack",
    "cpan",
    "ctest",
    "curl",
    "docker",
    "doom",
    "emacs",
    "exiftool",
    "fd",
    "ffmpeg",
    "find",
    "fish",
    "flake8",
    "gcc",
    "gcloud",
    "gem",
    "gfortran",
    "gh",
    "ghcup",
    "git",
    "go",
    "gpg",
    "gpg-agent",
    "gpg-connect-agent",
    "gpgconf",
    "grep",
    "gs",
    "h5cc",
    "hisat2",
    "hisat2-build",
    "hisat2-extract-exons",
    "hisat2-extract-splice-sites",
    "jar",
    "java",
    "javac",
    "jq",
    "julia",
    "kallisto",
    "ld",
    "lesspipe",
    "libtool",
    "libtoolize",
    "localedef",
    "lpr",
    "lua",
    "luac",
    "luajit",
    "luarocks",
    "lz4",
    "lzip",
    "lzma",
    "magick",
    "make",
    "mamba",
    "man",
    "md5sum",
    "meson",
    "minimap2",
    "miso-exon-utils",
    "miso-index-gff",
    "miso-pe-utils",
    "msgfmt",
    "msgmerge",
    "neofetch",
    "nim",
    "nimble",
    "ninja",
    "node",
    "npm",
    "nproc",
    "numfmt",
    "openssl",
    "parallel",
    "pbzip2",
    "pcre2-config",
    "pcregrep",
    "perl",
    "pigz",
    "pkg-config",
    "prettier",
    "proj",
    "pup",
    "pyenv",
    "pylint",
    "pytest",
    "python",
    "r",
    "ranlib",
    "rbenv",
    "rename",
    "rev",
    "rg",
    "rmats",
    "ronn",
    "rsem-calculate-expression",
    "rsem-prepare-reference",
    "rsync",
    "ruby",
    "rustc",
    "salmon",
    "sam-dump",
    "sambamba",
    "samtools",
    "scons",
    "scp",
    "shellcheck",
    "shunit2",
    "sox",
    "sra-prefetch",
    "ssh-add",
    "ssh-keygen",
    "ssh",
    "stack",
    "star",
    "svn",
    "swift",
    "swig",
    "tac",
    "tex",
    "texi2dvi",
    "tlmgr",
    "uncompress",
    "unzip",
    "uv",
    "vim",
    "wget",
    "xz",
    "yacc",
    "yq",
    "yt-dlp",
    "zcat",
    "zip",
    "zstd",
)

# Special locators with distinct app_name/bin_name
_SPECIAL = {
    "anaconda_conda": ("anaconda", "conda"),
    "anaconda_python": ("anaconda", "python"),
    "cc": ("gcc", "cc"),
    "clangxx": ("clang", "clang++"),
    "conda_python": ("conda", "python"),
    "cxx": ("gcc", "c++"),
    "efetch": ("entrez-direct", "efetch"),
    "esearch": ("entrez-direct", "esearch"),
    "fasterq_dump": ("sra-tools", "fasterq-dump"),
    "gcxx": ("gcc", "g++"),
    "gdal_config": ("gdal", "gdal-config"),
    "geos_config": ("geos", "geos-config"),
    "gsl_config": ("gsl", "gsl-config"),
    "icu_config": ("icu4c", "icu-config"),
    "koopa": ("koopa", "koopa"),
    "magick_core_config": ("imagemagick", "MagickCore-config"),
    "python310": ("python3.10", "python3.10"),
    "python311": ("python3.11", "python3.11"),
    "python312": ("python3.12", "python3.12"),
    "python313": ("python3.13", "python3.13"),
    "python314": ("python3.14", "python3.14"),
    "rscript": ("r", "Rscript"),
    "system_python": ("python", "python3"),
    "system_r": ("r", "R"),
    "system_rscript": ("r", "Rscript"),
}

# Build the registry dynamically
_REGISTRY: dict[str, Callable[..., str]] = {}

for _name in _SYSTEM_TOOLS:
    _key = _name.replace("-", "_")
    _REGISTRY[_key] = _make_locator(_name, only_system=True)

for _name in _KOOPA_APPS:
    _key = _name.replace("-", "_")
    if _key not in _REGISTRY:
        _REGISTRY[_key] = _make_locator(_name, allow_system=True)

for _key, (_app, _bin) in _SPECIAL.items():
    _REGISTRY[_key] = _make_locator(_app, _bin, allow_system=True)


def locate(
    name: str,
    *,
    allow_bootstrap: bool = False,
    allow_koopa_bin: bool = True,
    allow_missing: bool = False,
    allow_opt_bin: bool = True,
    allow_system: bool = False,
    only_bootstrap: bool = False,
    only_system: bool = False,
) -> str:
    """Dynamic locator dispatcher.

    Usage:
        locate("bash")
        locate("python3.14")
        locate("samtools")
    """
    key = name.replace("-", "_").replace(".", "")
    if key in _REGISTRY:
        return _REGISTRY[key](
            allow_bootstrap=allow_bootstrap,
            allow_koopa_bin=allow_koopa_bin,
            allow_missing=allow_missing,
            allow_opt_bin=allow_opt_bin,
            allow_system=allow_system,
            only_bootstrap=only_bootstrap,
            only_system=only_system,
        )
    return locate_app(
        name,
        allow_bootstrap=allow_bootstrap,
        allow_koopa_bin=allow_koopa_bin,
        allow_missing=allow_missing,
        allow_opt_bin=allow_opt_bin,
        allow_system=allow_system,
        only_bootstrap=only_bootstrap,
        only_system=only_system,
    )


# Convenience: expose top-level functions for common tools
locate_bash = _REGISTRY["bash"]
locate_python = _REGISTRY["python"]
locate_git = _REGISTRY["git"]
locate_r = _REGISTRY.get("r")
locate_conda = _REGISTRY.get("conda")
locate_brew = _REGISTRY.get("brew")
locate_docker = _REGISTRY.get("docker")
locate_curl = _REGISTRY.get("curl")
locate_wget = _REGISTRY.get("wget")
locate_make = _REGISTRY.get("make")
locate_gcc = _REGISTRY.get("gcc")
locate_cmake = _REGISTRY.get("cmake")
locate_node = _REGISTRY.get("node")
locate_npm = _REGISTRY.get("npm")
locate_cargo = _REGISTRY.get("cargo")
locate_rustc = _REGISTRY.get("rustc")
locate_ruby = _REGISTRY.get("ruby")
locate_perl = _REGISTRY.get("perl")
locate_java = _REGISTRY.get("java")
locate_go = _REGISTRY.get("go")
locate_julia = _REGISTRY.get("julia")
locate_samtools = _REGISTRY.get("samtools")
locate_salmon = _REGISTRY.get("salmon")
locate_star = _REGISTRY.get("star")
locate_rscript = _REGISTRY.get("rscript")
