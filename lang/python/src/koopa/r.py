"""R language configuration and helper functions.

Converted from Bash functions in ``lang/bash/functions/r/``.
"""

import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from . import prefix as pfx


def _rscript(*args: str, capture: bool = True) -> subprocess.CompletedProcess:
    """Run an Rscript command.

    Parameters
    ----------
    *args : str
        Command-line arguments to pass to Rscript.
    capture : bool, optional
        Capture stdout and stderr instead of streaming them to the terminal.

    Returns
    -------
    subprocess.CompletedProcess
        Completed process result from running Rscript.
    """
    cmd = ["Rscript", *args]
    return subprocess.run(cmd, capture_output=capture, text=True, check=True)


def _r_eval(code: str, *, capture: bool = True) -> subprocess.CompletedProcess:
    """Evaluate R code.

    Parameters
    ----------
    code : str
        R code to evaluate.
    capture : bool, optional
        Capture stdout and stderr instead of streaming them to the terminal.

    Returns
    -------
    subprocess.CompletedProcess
        Completed process result from evaluating the R code.
    """
    return _rscript("-e", code, capture=capture)


def r_version() -> str:
    """Get R version string.

    Returns
    -------
    str
        R version string reported by ``R.version.string``.
    """
    result = _r_eval("cat(R.version.string)")
    return result.stdout.strip()


def r_prefix(r_cmd: str | None = None) -> str:
    """Get R home directory.

    Parameters
    ----------
    r_cmd : str | None, optional
        Path to an R executable, used to derive the Rscript path to query.

    Returns
    -------
    str
        R home directory path.
    """
    if r_cmd is not None:
        rscript = r_cmd.replace("/R", "/Rscript")
        if not os.path.isfile(rscript):
            rscript = "Rscript"
        result = subprocess.run(
            [rscript, "-e", "cat(R.home())"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    result = _r_eval("cat(R.home())")
    return result.stdout.strip()


def r_library_prefix() -> str:
    """Get R library path.

    Returns
    -------
    str
        Path to the first entry in R's library search path.
    """
    result = _r_eval("cat(.libPaths()[1L])")
    return result.stdout.strip()


def r_system_library_prefix() -> str:
    """Get R system library path.

    Returns
    -------
    str
        Path to R's system library directory.
    """
    result = _r_eval("cat(.Library)")
    return result.stdout.strip()


def r_packages_prefix() -> str:
    """Get R packages install prefix.

    Returns
    -------
    str
        Installation prefix directory for R packages.
    """
    return os.path.join(pfx.koopa_prefix(), "app", "r-packages")


def r_scripts_prefix() -> str:
    """Get R scripts prefix.

    Returns
    -------
    str
        Path to the R scripts directory.
    """
    return os.path.join(pfx.r_prefix(), "scripts")


def r_package_version(package: str) -> str:
    """Get version of an installed R package.

    Parameters
    ----------
    package : str
        Name of the installed R package.

    Returns
    -------
    str
        Installed version string of the package.
    """
    result = _r_eval(f'cat(as.character(packageVersion("{package}")))')
    return result.stdout.strip()


def r_paste_to_vector(items: list[str]) -> str:
    """Convert a Python list to an R character vector string.

    Parameters
    ----------
    items : list[str]
        Strings to quote and join into an R character vector.

    Returns
    -------
    str
        R character vector literal, e.g. ``c("a", "b")``.
    """
    quoted = ", ".join(f'"{x}"' for x in items)
    return f"c({quoted})"


def r_system_packages_non_base() -> list[str]:
    """Get non-base system packages.

    Returns
    -------
    list[str]
        Names of installed packages that are not part of R's base priority set.
    """
    code = (
        "pkgs <- installed.packages(lib.loc = .Library);"
        'base <- installed.packages(priority = "base");'
        'cat(setdiff(rownames(pkgs), rownames(base)), sep = "\\n")'
    )
    result = _r_eval(code)
    return [x for x in result.stdout.strip().splitlines() if x]


def install_packages_in_site_library(packages: list[str]) -> None:
    """Install R packages in site library.

    Parameters
    ----------
    packages : list[str]
        Names of R packages to install.
    """
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
    """Migrate non-base packages between libraries.

    Parameters
    ----------
    from_lib : str
        Library path to migrate packages from.
    to_lib : str
        Library path to migrate packages to.
    """
    code = (
        f'pkgs <- installed.packages(lib.loc = "{from_lib}");'
        'base_pkgs <- installed.packages(priority = "base");'
        "pkgs <- setdiff(rownames(pkgs), rownames(base_pkgs));"
        f'install.packages(pkgs, lib = "{to_lib}")'
    )
    _r_eval(code, capture=False)


def _r_major_minor(r_home: str) -> str:
    """Get major.minor version from an R installation.

    Parameters
    ----------
    r_home : str
        Path to the R home directory.

    Returns
    -------
    str
        Major.minor version string, e.g. ``"4.3"``.
    """
    rscript = os.path.join(r_home, "bin", "Rscript")
    if not os.path.isfile(rscript):
        rscript = "Rscript"
    result = subprocess.run(
        [rscript, "-e", 'cat(paste0(R.version$major, ".", R.version$minor))'],
        capture_output=True,
        text=True,
        check=True,
    )
    ver = result.stdout.strip()
    parts = ver.split(".")
    return f"{parts[0]}.{parts[1]}"


def configure_r_environ(
    r_home: str | None = None,
    *,
    name: str = "r",
    system: bool = False,
) -> None:
    """Configure R environ file.

    Parameters
    ----------
    r_home : str | None, optional
        Path to the R home directory. Defaults to the current R installation.
    name : str, optional
        Application name, used to detect an "r-devel" build.
    system : bool, optional
        Configure a system-wide R environ instead of a user one.
    """
    if r_home is None:
        r_home = r_prefix()
    environ_file = os.path.join(r_home, "etc", "Renviron.site")
    lines: list[str] = []
    if system:
        lines.append(f'R_LIBS_USER="{r_library_prefix()}"')
    else:
        suffix = "devel" if name == "r-devel" else _r_major_minor(r_home)
        lines.append(f'R_LIBS_USER="${{TMPDIR}}/koopa-R-{suffix}/library"')
    Path(environ_file).write_text("\n".join(lines) + "\n")


def configure_r_makevars(r_home: str | None = None) -> None:
    """Configure R Makevars file.

    Parameters
    ----------
    r_home : str | None, optional
        Path to the R home directory. Defaults to the current R installation.
    """
    if r_home is None:
        r_home = r_prefix()
    makevars_file = os.path.join(r_home, "etc", "Makevars.site")
    lines: list[str] = []
    Path(makevars_file).write_text("\n".join(lines) + "\n")


def configure_r_java() -> None:
    """Configure R Java support."""
    subprocess.run(["R", "CMD", "javareconf"], check=True)


def _r_build_source(path: str, build_dir: Path) -> Path:
    """Build a source tarball for R CMD check.

    Parameters
    ----------
    path : str
        Path to the R package source directory.
    build_dir : Path
        Directory in which to run ``R CMD build``.

    Returns
    -------
    Path
        Path to the built source tarball.
    """
    subprocess.run(
        ["R", "CMD", "build", path],
        cwd=build_dir,
        check=True,
    )
    tarballs = list(build_dir.glob("*.tar.gz"))
    if len(tarballs) != 1:
        msg = f"Expected one source tarball in '{build_dir}', found {len(tarballs)}."
        raise RuntimeError(msg)
    return tarballs[0]


def r_check(path: str) -> None:
    """Build an R package source tarball and run R CMD check on it.

    Parameters
    ----------
    path : str
        Path to the R package source directory to check.
    """
    package_dir = Path(path).expanduser().resolve()
    with tempfile.TemporaryDirectory(prefix="koopa-r-check-") as tmp_dir:
        tarball = _r_build_source(str(package_dir), Path(tmp_dir))
        subprocess.run(
            ["R", "CMD", "check", "--as-cran", "--no-manual", str(tarball)],
            cwd=tmp_dir,
            check=True,
        )


def r_script(script: str) -> None:
    """Run an R script file.

    Parameters
    ----------
    script : str
        Path to the R script file to run.
    """
    _rscript(script, capture=False)


def r_shiny_run_app(app_dir: str, *, port: int = 3838) -> None:
    """Run a Shiny app.

    Parameters
    ----------
    app_dir : str
        Path to the Shiny application directory.
    port : int, optional
        TCP port on which to serve the app.
    """
    code = f'shiny::runApp("{app_dir}", port = {port}, launch.browser = FALSE)'
    _r_eval(code, capture=False)


def _is_koopa_app(path: str) -> bool:
    """Check if a path is within the koopa app prefix.

    Parameters
    ----------
    path : str
        Filesystem path to check.

    Returns
    -------
    bool
        True if the resolved path is within the koopa app prefix.
    """
    app_dir = pfx.app_prefix()
    if not os.path.isdir(app_dir):
        return False
    real = os.path.realpath(path)
    return real.startswith(app_dir)


def r_bioconda_check(*packages: str) -> None:
    """Acid Genomics Bioconda recipe R CMD check workflow.

    Parameters
    ----------
    *packages : str
        Names of Bioconda R packages to check.
    """
    import tempfile

    if not packages:
        msg = "Package names required."
        raise ValueError(msg)
    with tempfile.TemporaryDirectory() as tmp_dir:
        for pkg in packages:
            pkg_lower = pkg.lower()
            pkg2 = f"r-{pkg_lower}"
            work_dir = os.path.join(tmp_dir, pkg2)
            os.makedirs(work_dir, exist_ok=True)
            conda_prefix = os.path.join(work_dir, "conda")
            tarball_url = (
                f"https://github.com/acidgenomics/{pkg2}/archive/refs/heads/develop.tar.gz"
            )
            rscript_path = os.path.join(work_dir, "check.R")
            rscript_content = (
                "pkgbuild::check_build_tools(debug = TRUE)\n"
                "install.packages(\n"
                '    pkgs = c("AcidDevTools", "AcidTest"),\n'
                "    repos = c(\n"
                '        "https://r.acidgenomics.com",\n'
                "        BiocManager::repositories()\n"
                "    ),\n"
                "    dependencies = FALSE\n"
                ")\n"
                'AcidDevTools::check("src")\n'
            )
            Path(rscript_path).write_text(rscript_content)
            print(f"Checking '{pkg}' in '{work_dir}'.")
            conda = shutil.which("conda")
            if conda is None:
                msg = "conda is required."
                raise RuntimeError(msg)
            conda_deps = [
                "r-biocmanager",
                "r-desc",
                "r-goalie",
                "r-knitr",
                "r-rcmdcheck",
                "r-rmarkdown",
                "r-testthat",
                "r-urlchecker",
                pkg2,
            ]
            subprocess.run(
                [conda, "create", "--yes", "--prefix", conda_prefix, *conda_deps],
                check=True,
            )
            tarball_file = os.path.join(work_dir, "develop.tar.gz")
            from koopa.download import download

            download(tarball_url, tarball_file)
            subprocess.run(
                ["tar", "xzf", tarball_file, "-C", work_dir],
                check=True,
            )
            src_dirs = [
                d
                for d in os.listdir(work_dir)
                if os.path.isdir(os.path.join(work_dir, d))
                and d not in ("conda",)
                and d.startswith(pkg2)
            ]
            if src_dirs:
                src = os.path.join(work_dir, src_dirs[0])
                dst = os.path.join(work_dir, "src")
                os.rename(src, dst)
            rscript_bin = os.path.join(conda_prefix, "bin", "Rscript")
            subprocess.run([rscript_bin, rscript_path], check=True)


def r_configure_ldpaths(r_cmd: str) -> None:
    """Configure ldpaths file for R LD linker configuration.

    Parameters
    ----------
    r_cmd : str
        Path to the R executable to configure ldpaths for.
    """
    from koopa.system import arch, is_linux, is_macos

    is_system = not _is_koopa_app(r_cmd)
    use_apps = not is_system
    cpu_arch = arch()
    if is_macos() and cpu_arch == "aarch64":
        cpu_arch = "arm64"
    if use_apps:
        java_home = pfx.app_prefix("temurin")
    elif is_linux():
        java_home = "/usr/lib/jvm/default-java"
    elif is_macos():
        result = subprocess.run(
            ["/usr/libexec/java_home"],
            capture_output=True,
            text=True,
            check=True,
        )
        java_home = result.stdout.strip()
    else:
        msg = "Unsupported platform."
        raise RuntimeError(msg)
    if not os.path.isdir(java_home):
        msg = f"JAVA_HOME does not exist: '{java_home}'."
        raise FileNotFoundError(msg)
    lines: list[str] = []
    lines.append(f": ${{JAVA_HOME={java_home}}}")
    if is_macos():
        lines.append(
            ": ${R_JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/libexec/Contents/Home/lib/server}",
        )
    else:
        lines.append(
            ": ${R_JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/libexec/lib/server}",
        )
    ld_lib: list[str] = ["${R_HOME}/lib"]
    if use_apps:
        from koopa.io import import_app_json

        app_json = import_app_json()
        app_keys = sorted(app_json.get("r", {}).get("dependencies", []))
        for key in app_keys:
            lib_dir = os.path.join(pfx.app_prefix(key), "lib")
            if os.path.isdir(lib_dir):
                ld_lib.append(lib_dir)
    if is_linux():
        sys_libdir = f"/usr/lib/{cpu_arch}-linux-gnu"
        ld_lib.extend([sys_libdir, "/usr/lib", "/lib"])
    ld_lib.append("${R_JAVA_LD_LIBRARY_PATH}")
    library_path = ":".join(ld_lib) + ":"
    lines.append(f'R_LD_LIBRARY_PATH="{library_path}"')
    if is_linux():
        lines.append('LD_LIBRARY_PATH="${R_LD_LIBRARY_PATH}"')
        lines.append("export LD_LIBRARY_PATH")
    elif is_macos():
        lines.append('DYLD_FALLBACK_LIBRARY_PATH="${R_LD_LIBRARY_PATH}"')
        lines.append("export DYLD_FALLBACK_LIBRARY_PATH")
    r_home = r_prefix(r_cmd)
    ldpaths_file = os.path.join(r_home, "etc", "ldpaths")
    ldpaths_bak = ldpaths_file + ".bak"
    if not os.path.isfile(ldpaths_file):
        msg = f"ldpaths file not found: '{ldpaths_file}'."
        raise FileNotFoundError(msg)
    content = "\n".join(lines) + "\n"
    print(f"Modifying '{ldpaths_file}'.")
    if is_system:
        if not os.path.isfile(ldpaths_bak):
            subprocess.run(
                ["sudo", "cp", ldpaths_file, ldpaths_bak],
                check=True,
            )
        subprocess.run(["sudo", "rm", "-f", ldpaths_file], check=True)
        subprocess.run(
            ["sudo", "tee", ldpaths_file],
            input=content,
            text=True,
            check=True,
            capture_output=True,
        )
        subprocess.run(
            ["sudo", "chmod", "0644", ldpaths_file],
            check=True,
        )
    else:
        if not os.path.isfile(ldpaths_bak):
            shutil.copy2(ldpaths_file, ldpaths_bak)
        Path(ldpaths_file).write_text(content)


def r_gfortran_libs() -> str:
    """Define FLIBS for R gfortran configuration.

    Returns
    -------
    str
        Space-separated FLIBS linker flags for gfortran.
    """
    from koopa.system import arch, is_linux, is_macos

    cpu_arch = arch()
    flibs: list[str] = []
    if is_linux():
        pass
    elif is_macos():
        search_arch = "aarch64" if cpu_arch == "arm64" else cpu_arch
        lib_prefix = "/opt/gfortran/lib"
        if not os.path.isdir(lib_prefix):
            msg = f"gfortran lib prefix not found: '{lib_prefix}'."
            raise FileNotFoundError(msg)
        lib_dirs: list[str] = []
        for root, _dirs, files in os.walk(lib_prefix):
            if "libgfortran.a" in files:
                lib_dirs.append(root)
        lib_dirs.sort()
        arch_dirs = [d for d in lib_dirs if f"/{search_arch}-" in d]
        if not arch_dirs:
            msg = f"No gfortran libs found for architecture '{search_arch}'."
            raise RuntimeError(msg)
        for d in arch_dirs:
            flibs.append(f"-L{d}")
        flibs.append(f"-L{lib_prefix}")
    flibs.append("-lgfortran")
    if is_linux():
        flibs.append("-lm")
    if cpu_arch == "x86_64":
        flibs.append("-lquadmath")
    return " ".join(flibs)


def r_copy_files_into_etc(r_cmd: str) -> None:
    """Copy R config files into etc/.

    Parameters
    ----------
    r_cmd : str
        Path to the R executable whose ``etc/`` directory receives the copied
        config files.
    """
    is_system = not _is_koopa_app(r_cmd)
    r_home = r_prefix(r_cmd)
    koopa_etc = os.path.join(pfx.koopa_prefix(), "etc", "R")
    r_etc = os.path.join(r_home, "etc")
    for name in ("Rprofile.site", "repositories"):
        src = os.path.join(koopa_etc, name)
        tgt = os.path.join(r_etc, name)
        if not os.path.isfile(src):
            msg = f"Source file not found: '{src}'."
            raise FileNotFoundError(msg)
        if os.path.islink(tgt):
            real_tgt = os.path.realpath(tgt)
            if real_tgt == f"/etc/R/{name}":
                tgt = real_tgt
        print(f"Modifying '{tgt}'.")
        if is_system:
            subprocess.run(["sudo", "cp", src, tgt], check=True)
            subprocess.run(["sudo", "chmod", "0644", tgt], check=True)
        else:
            shutil.copy2(src, tgt)
