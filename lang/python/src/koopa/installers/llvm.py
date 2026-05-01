"""Install llvm."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, app_prefix, cmake_build, locate, shared_ext
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install llvm."""
    build_deps = ["git", "perl", "pkg-config", "swig"]
    env = activate_app(*build_deps, build_only=True)
    deps = ["xz", "zlib", "zstd", "libedit", "libffi", "ncurses", "python"]
    if sys.platform != "darwin":
        deps.extend(["binutils", "elfutils"])
    env = activate_app(*deps, env=env)
    ext = shared_ext()
    libedit_prefix = app_prefix("libedit")
    libffi_prefix = app_prefix("libffi")
    ncurses_prefix = app_prefix("ncurses")
    python_prefix = app_prefix("python")
    xz_prefix = app_prefix("xz")
    zlib_prefix = app_prefix("zlib")
    zstd_prefix = app_prefix("zstd")
    git = locate("git")
    perl = locate("perl")
    pkg_config = locate("pkg-config")
    python_bin = locate("python3")
    swig = locate("swig")
    py_ver = (
        subprocess.run(
            [python_bin, "--version"],
            capture_output=True,
            text=True,
            check=True,
        )
        .stdout.strip()
        .split()[-1]
    )
    py_maj_min = major_minor_version(py_ver)
    projects = ";".join(
        [
            "clang",
            "clang-tools-extra",
            "flang",
            "lld",
            "lldb",
            "mlir",
            "openmp",
            "polly",
        ]
    )
    runtimes = ";".join(["libcxx", "libcxxabi", "libunwind"])
    url = (
        f"https://github.com/llvm/llvm-project/releases/download/"
        f"llvmorg-{version}/llvm-project-{version}.src.tar.xz"
    )
    download_extract_cd(url)
    os.chdir("llvm")
    cmake_args = [
        f"-DCURSES_INCLUDE_DIRS={ncurses_prefix}/include",
        f"-DCURSES_LIBRARIES={ncurses_prefix}/lib/libncursesw.{ext}",
        f"-DFFI_INCLUDE_DIR={libffi_prefix}/include",
        f"-DFFI_LIBRARY_DIR={libffi_prefix}/lib",
        f"-DGIT_EXECUTABLE={git}",
        f"-DLIBLZMA_INCLUDE_DIR={xz_prefix}/include",
        f"-DLIBLZMA_LIBRARY={xz_prefix}/lib/liblzma.{ext}",
        f"-DLibEdit_INCLUDE_DIRS={libedit_prefix}/include",
        f"-DLibEdit_LIBRARIES={libedit_prefix}/lib/libedit.{ext}",
        f"-DPANEL_LIBRARIES={ncurses_prefix}/lib/libpanelw.{ext}",
        f"-DPERL_EXECUTABLE={perl}",
        f"-DPKG_CONFIG_EXECUTABLE={pkg_config}",
        f"-DPython3_EXECUTABLE={python_bin}",
        f"-DPython3_INCLUDE_DIRS={python_prefix}/include",
        f"-DPython3_LIBRARIES={python_prefix}/lib/libpython{py_maj_min}.{ext}",
        f"-DPython3_ROOT_DIR={python_prefix}",
        f"-DSWIG_EXECUTABLE={swig}",
        f"-DTerminfo_LIBRARIES={ncurses_prefix}/lib/libncursesw.{ext}",
        f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
        f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        f"-DZstd_INCLUDE_DIR={zstd_prefix}/include",
        f"-DZstd_LIBRARY={zstd_prefix}/lib/libzstd.{ext}",
    ]
    if sys.platform == "darwin":
        cmake_args.extend(
            [
                f"-DLLVM_ENABLE_PROJECTS={projects}",
                f"-DLLVM_ENABLE_RUNTIMES={runtimes}",
                "-DLLVM_CREATE_XCODE_TOOLCHAIN=OFF",
            ]
        )
    else:
        binutils_prefix = app_prefix("binutils")
        elfutils_prefix = app_prefix("elfutils")
        cmake_args.extend(
            [
                f"-DLIBOMPTARGET_DEP_LIBELF_INCLUDE_DIR={elfutils_prefix}/include",
                f"-DLIBOMPTARGET_DEP_LIBELF_LIBRARIES={elfutils_prefix}/lib/libelf.{ext}",
                f"-DLLVM_BINUTILS_INCDIR={binutils_prefix}/include",
            ]
        )
    cmake_build(prefix=prefix, args=cmake_args, env=env)
