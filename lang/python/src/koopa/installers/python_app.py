"""Install python."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, app_prefix, locate
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd
from koopa.system import has_firewall
from koopa.version import major_minor_version, major_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install python."""
    if has_firewall():
        _install_from_source(version=version, prefix=prefix)
    else:
        _install_from_uv(version=version, prefix=prefix)


def _install_from_source(*, version: str, prefix: str) -> None:
    env = activate_app("make", "pkg-config", build_only=True)
    deps = []
    if sys.platform != "darwin":
        deps.extend(
            [
                "bzip2",
                "libedit",
                "libffi",
                "libxcrypt",
                "ncurses",
                "readline",
                "unzip",
                "zlib",
            ]
        )
    deps.extend(["expat", "mpdecimal", "openssl3", "sqlite", "xz"])
    env = activate_app(*deps, env=env)
    make = locate("make")
    openssl_prefix = app_prefix("openssl3")
    maj_min_ver = major_minor_version(version)
    os.makedirs(os.path.join(prefix, "bin"), exist_ok=True)
    os.makedirs(os.path.join(prefix, "lib"), exist_ok=True)
    base_url = os.environ.get("PYTHON_BUILD_MIRROR_URL", "https://www.python.org/ftp/python")
    url = f"{base_url}/{version}/Python-{version}.tar.xz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess_env["PATH"] = os.path.join(prefix, "bin") + ":" + subprocess_env.get("PATH", "")
    ldflags = subprocess_env.get("LDFLAGS", "")
    subprocess_env["LDFLAGS"] = f"-Wl,-rpath,{prefix}/lib {ldflags}"
    conf_args = [
        "--enable-ipv6",
        "--enable-loadable-sqlite-extensions",
        "--enable-optimizations",
        "--enable-shared",
        f"--prefix={prefix}",
        "--with-computed-gotos",
        "--with-ensurepip=install",
        f"--with-openssl={openssl_prefix}",
        "PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1",
        "ac_cv_working_openssl_hashlib=yes",
        "ac_cv_working_openssl_ssl=yes",
        "py_cv_module__gdbm=disabled",
        "py_cv_module__tkinter=disabled",
    ]
    if sys.platform == "darwin":
        conf_args.append("--with-dtrace=/usr/sbin/dtrace")
        arch = os.uname().machine
        decimal_arch = "uint128" if arch in ("aarch64", "arm64") else "x64"
        with open("configure") as fh:
            text = fh.read()
        text = text.replace(
            "libmpdec_machine=universal",
            f"libmpdec_machine={decimal_arch}",
        )
        with open("configure", "w") as fh:
            fh.write(text)
        subprocess_env["PYTHON_DECIMAL_WITH_MACHINE"] = decimal_arch
    subprocess.run(
        ["./configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, "VERBOSE=1", f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
    python = os.path.join(prefix, "bin", f"python{maj_min_ver}")
    for mod in (
        "_bz2",
        "_ctypes",
        "_decimal",
        "hashlib",
        "pyexpat",
        "readline",
        "sqlite3",
        "ssl",
        "zlib",
    ):
        subprocess.run([python, "-c", f"import {mod}"], check=True)
    _create_unversioned_symlinks(prefix)


def _install_from_uv(*, version: str, prefix: str) -> None:
    uv = locate("uv")
    maj_min_ver = major_minor_version(version)
    subprocess.run(
        [
            uv,
            "python",
            "install",
            "--install-dir",
            "uv",
            "--no-bin",
            "--no-cache",
            "--no-config",
            "--verbose",
            version,
        ],
        check=True,
    )
    uv_dir = "uv"
    entries = os.listdir(uv_dir)
    if len(entries) == 1:
        source_dir = os.path.join(uv_dir, entries[0])
    else:
        source_dir = uv_dir
    for item in os.listdir(source_dir):
        src = os.path.join(source_dir, item)
        dst = os.path.join(prefix, item)
        if os.path.isdir(src):
            import shutil

            shutil.copytree(src, dst, dirs_exist_ok=True)
        else:
            import shutil

            shutil.copy2(src, dst)
    python = os.path.join(prefix, "bin", f"python{maj_min_ver}")
    for mod in (
        "_bz2",
        "_ctypes",
        "_decimal",
        "hashlib",
        "pyexpat",
        "readline",
        "sqlite3",
        "ssl",
        "zlib",
    ):
        subprocess.run([python, "-c", f"import {mod}"], check=True)
    _create_unversioned_symlinks(prefix)


def _create_unversioned_symlinks(prefix: str) -> None:
    bin_dir = os.path.join(prefix, "bin")
    for src, dst in [
        ("idle3", "idle"),
        ("pip3", "pip"),
        ("pydoc3", "pydoc"),
        ("python3", "python"),
        ("python3-config", "python-config"),
    ]:
        src_path = os.path.join(bin_dir, src)
        if os.path.exists(src_path):
            ln(src, os.path.join(bin_dir, dst))
    man_dir = os.path.join(prefix, "share", "man", "man1")
    if os.path.isdir(man_dir):
        src_man = os.path.join(man_dir, "python3.1")
        if os.path.exists(src_man):
            ln("python3.1", os.path.join(man_dir, "python.1"))
