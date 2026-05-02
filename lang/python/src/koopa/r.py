"""R language configuration and helper functions.

Converted from Bash functions in ``lang/bash/functions/r/``.
"""

from __future__ import annotations

import os
import platform
import shutil
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


def r_prefix(r_cmd: str | None = None) -> str:
    """Get R home directory."""
    if r_cmd is not None:
        rscript = r_cmd.replace("/R", "/Rscript")
        if not os.path.isfile(rscript):
            rscript = "Rscript"
        result = subprocess.run(
            [rscript, "-e", "cat(R.home())"],
            capture_output=True, text=True, check=True,
        )
        return result.stdout.strip()
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


def _is_koopa_app(path: str) -> bool:
    """Check if a path is within the koopa app prefix."""
    app_dir = pfx.app_prefix()
    if not os.path.isdir(app_dir):
        return False
    real = os.path.realpath(path)
    return real.startswith(app_dir)


def r_bioconda_check(*packages: str) -> None:
    """Acid Genomics Bioconda recipe R CMD check workflow."""
    import tempfile

    if not packages:
        msg = "Package name(s) required."
        raise ValueError(msg)
    with tempfile.TemporaryDirectory() as tmp_dir:
        for pkg in packages:
            pkg_lower = pkg.lower()
            pkg2 = f"r-{pkg_lower}"
            work_dir = os.path.join(tmp_dir, pkg2)
            os.makedirs(work_dir, exist_ok=True)
            conda_prefix = os.path.join(work_dir, "conda")
            tarball_url = (
                f"https://github.com/acidgenomics/{pkg2}/"
                "archive/refs/heads/develop.tar.gz"
            )
            rscript_path = os.path.join(work_dir, "check.R")
            rscript_content = (
                'pkgbuild::check_build_tools(debug = TRUE)\n'
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
                "r-biocmanager", "r-desc", "r-goalie", "r-knitr",
                "r-rcmdcheck", "r-rmarkdown", "r-testthat",
                "r-urlchecker", pkg2,
            ]
            subprocess.run(
                [conda, "create", "--yes", "--prefix", conda_prefix,
                 *conda_deps],
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
                d for d in os.listdir(work_dir)
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
    """Configure ldpaths file for R LD linker configuration."""
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
            capture_output=True, text=True, check=True,
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
            ": ${R_JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/"
            "libexec/Contents/Home/lib/server}",
        )
    else:
        lines.append(
            ": ${R_JAVA_LD_LIBRARY_PATH=${JAVA_HOME}/"
            "libexec/lib/server}",
        )
    ld_lib: list[str] = ["${R_HOME}/lib"]
    if use_apps:
        app_keys = [
            "cairo", "curl", "fontconfig", "freetype", "fribidi",
            "gdal", "geos", "glib", "harfbuzz", "hdf5", "icu4c",
            "imagemagick", "libffi", "libgit2", "libiconv",
            "libjpeg-turbo", "libpng", "libssh2", "libtiff", "libxml2",
            "openssl", "pcre", "pcre2", "pixman", "proj", "readline",
            "sqlite", "xorg-libice", "xorg-libpthread-stubs",
            "xorg-libsm", "xorg-libx11", "xorg-libxau", "xorg-libxcb",
            "xorg-libxdmcp", "xorg-libxext", "xorg-libxrandr",
            "xorg-libxrender", "xorg-libxt", "xz", "zlib", "zstd",
        ]
        if not is_macos():
            app_keys.insert(0, "bzip2")
        if is_macos() or not is_system:
            app_keys.append("gettext")
        for key in app_keys:
            lib_dir = os.path.join(pfx.app_prefix(key), "lib")
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
                ["sudo", "cp", ldpaths_file, ldpaths_bak], check=True,
            )
        subprocess.run(["sudo", "rm", "-f", ldpaths_file], check=True)
        subprocess.run(
            ["sudo", "tee", ldpaths_file],
            input=content, text=True, check=True, capture_output=True,
        )
        subprocess.run(
            ["sudo", "chmod", "0644", ldpaths_file], check=True,
        )
    else:
        if not os.path.isfile(ldpaths_bak):
            shutil.copy2(ldpaths_file, ldpaths_bak)
        Path(ldpaths_file).write_text(content)


def r_gfortran_libs() -> str:
    """Define FLIBS for R gfortran configuration."""
    from koopa.system import arch, is_linux, is_macos

    cpu_arch = arch()
    flibs: list[str] = []
    if is_linux():
        pass
    elif is_macos():
        if cpu_arch == "arm64":
            search_arch = "aarch64"
        else:
            search_arch = cpu_arch
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
    """Copy R config files into etc/."""
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
