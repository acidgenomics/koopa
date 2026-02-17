"""R language configuration and helper functions.

Converted from Bash functions: r-version, r-library-prefix, r-script,
install-packages-in-site-library, remove-packages-in-system-library,
configure-r-environ, configure-r-makevars, configure-r-java, etc.
"""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

from . import prefix as pfx


def _rscript(*args: str, capture: bool = True) -> subprocess.CompletedProcess:
    """Run an Rscript command."""
    cmd = ["Rscript", *args]
    return subprocess.run(cmd, capture_output=capture, text=True, check=True)


def _r_eval(code: str, *, capture: bool = True) -> subprocess.CompletedProcess:
    """Evaluate R code."""
    return _rscript("-e", code, capture=capture)


def r_version() -> str:
    """Get R version string."""
    result = _r_eval("cat(R.version.string)")
    return result.stdout.strip()


def r_prefix() -> str:
    """Get R home directory."""
    result = _r_eval("cat(R.home())")
    return result.stdout.strip()


def r_library_prefix() -> str:
    """Get R library path."""
    result = _r_eval("cat(.libPaths()[1L])")
    return result.stdout.strip()


def r_system_library_prefix() -> str:
    """Get R system library path."""
    result = _r_eval("cat(.Library)")
    return result.stdout.strip()


def r_packages_prefix() -> str:
    """Get R packages install prefix."""
    return os.path.join(pfx.koopa_prefix(), "app", "r-packages")


def r_scripts_prefix() -> str:
    """Get R scripts prefix."""
    return os.path.join(pfx.r_prefix(), "scripts")


def r_package_version(package: str) -> str:
    """Get version of an installed R package."""
    result = _r_eval(f'cat(as.character(packageVersion("{package}")))')
    return result.stdout.strip()


def r_paste_to_vector(items: list[str]) -> str:
    """Convert a Python list to an R character vector string."""
    quoted = ", ".join(f'"{x}"' for x in items)
    return f"c({quoted})"


def r_system_packages_non_base() -> list[str]:
    """Get non-base system packages."""
    code = (
        "pkgs <- installed.packages(lib.loc = .Library);"
        'base <- installed.packages(priority = "base");'
        'cat(setdiff(rownames(pkgs), rownames(base)), sep = "\\n")'
    )
    result = _r_eval(code)
    return [x for x in result.stdout.strip().splitlines() if x]


def install_packages_in_site_library(packages: list[str]) -> None:
    """Install R packages in site library."""
    vec = r_paste_to_vector(packages)
    code = f"install.packages({vec}, lib = .libPaths()[1L])"
    _r_eval(code, capture=False)


def remove_packages_in_system_library() -> None:
    """Remove non-base packages from system library."""
    code = (
        "pkgs <- installed.packages(lib.loc = .Library);"
        'base_pkgs <- installed.packages(priority = "base");'
        "rm_pkgs <- setdiff(rownames(pkgs), rownames(base_pkgs));"
        "if (length(rm_pkgs) > 0L) remove.packages(rm_pkgs, lib = .Library)"
    )
    _r_eval(code, capture=False)


def r_migrate_non_base_packages(from_lib: str, to_lib: str) -> None:
    """Migrate non-base packages between libraries."""
    code = (
        f'pkgs <- installed.packages(lib.loc = "{from_lib}");'
        'base_pkgs <- installed.packages(priority = "base");'
        "pkgs <- setdiff(rownames(pkgs), rownames(base_pkgs));"
        f'install.packages(pkgs, lib = "{to_lib}")'
    )
    _r_eval(code, capture=False)


def configure_r_environ(r_home: str | None = None) -> None:
    """Configure R environ file."""
    if r_home is None:
        r_home = r_prefix()
    environ_file = os.path.join(r_home, "etc", "Renviron.site")
    lines = [
        f'R_LIBS_USER="{r_library_prefix()}"',
    ]
    Path(environ_file).write_text("\n".join(lines) + "\n")


def configure_r_makevars(r_home: str | None = None) -> None:
    """Configure R Makevars file."""
    if r_home is None:
        r_home = r_prefix()
    makevars_file = os.path.join(r_home, "etc", "Makevars.site")
    lines: list[str] = []
    Path(makevars_file).write_text("\n".join(lines) + "\n")


def configure_r_java() -> None:
    """Configure R Java support."""
    subprocess.run(["R", "CMD", "javareconf"], check=True)


def r_check(path: str) -> None:
    """Run R CMD check on a package."""
    subprocess.run(
        ["R", "CMD", "check", "--as-cran", "--no-manual", path],
        check=True,
    )


def r_script(script: str) -> None:
    """Run an R script file."""
    _rscript(script, capture=False)


def r_shiny_run_app(app_dir: str, *, port: int = 3838) -> None:
    """Run a Shiny app."""
    code = f'shiny::runApp("{app_dir}", port = {port}, launch.browser = FALSE)'
    _r_eval(code, capture=False)
