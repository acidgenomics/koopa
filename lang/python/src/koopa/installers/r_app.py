"""Install r."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.build import activate_app, app_prefix, locate
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r."""
    is_devel = name == "r-devel"
    build_deps = ["autoconf", "automake", "libtool", "make", "pkg-config"]
    env = activate_app(*build_deps, build_only=True)
    deps = []
    if sys.platform != "darwin":
        deps.append("bzip2")
    deps.extend(
        [
            "xz",
            "zlib",
            "zstd",
            "gettext",
            "icu4c",
            "readline",
            "openssl",
            "libssh2",
            "curl",
            "libjpeg-turbo",
            "libpng",
            "libtiff",
            "openblas",
            "pcre2",
            "texinfo",
            "libffi",
            "glib",
            "freetype",
            "libxml2",
            "fontconfig",
            "pixman",
            "xorg-xorgproto",
            "xorg-xcb-proto",
            "xorg-libpthread-stubs",
            "xorg-libice",
            "xorg-libsm",
            "xorg-libxau",
            "xorg-libxdmcp",
            "xorg-libxcb",
            "xorg-libx11",
            "xorg-libxext",
            "xorg-libxrender",
            "xorg-libxt",
            "cairo",
            "tcl-tk",
        ]
    )
    env = activate_app(*deps, env=env)
    make = locate("make")
    pkg_config = locate("pkg-config")
    tcl_tk_prefix = app_prefix("tcl-tk")
    subprocess_env = env.to_env_dict()
    blas_libs = subprocess.run(
        [pkg_config, "--libs", "openblas"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    cairo_libs = subprocess.run(
        [
            pkg_config,
            "--libs",
            "cairo",
            "cairo-fc",
            "cairo-ft",
            "cairo-pdf",
            "cairo-png",
            "cairo-ps",
            "cairo-script",
            "cairo-svg",
            "cairo-xcb",
            "cairo-xcb-shm",
            "cairo-xlib",
            "cairo-xlib-xrender",
        ],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    icu_libs = subprocess.run(
        [pkg_config, "--libs", "icu-i18n", "icu-io", "icu-uc"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    jpeg_libs = subprocess.run(
        [pkg_config, "--libs", "libjpeg"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    png_libs = subprocess.run(
        [pkg_config, "--libs", "libpng"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    tiff_libs = subprocess.run(
        [pkg_config, "--libs", "libtiff-4"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    pcre2_libs = subprocess.run(
        [
            pkg_config,
            "--libs",
            "libpcre2-8",
            "libpcre2-16",
            "libpcre2-32",
            "libpcre2-posix",
        ],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    readline_libs = subprocess.run(
        [pkg_config, "--libs", "readline"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    conf_args = [
        "--disable-static",
        "--enable-R-profiling",
        "--enable-R-shlib",
        "--enable-byte-compiled-packages",
        "--enable-fast-install",
        "--enable-java",
        "--enable-memory-profiling",
        "--enable-shared",
        f"--prefix={prefix}",
        f"--with-ICU={icu_libs}",
        f"--with-blas={blas_libs}",
        f"--with-cairo={cairo_libs}",
        f"--with-jpeglib={jpeg_libs}",
        f"--with-libpng={png_libs}",
        f"--with-libtiff={tiff_libs}",
        f"--with-pcre2={pcre2_libs}",
        f"--with-readline={readline_libs}",
        f"--with-tcl-config={tcl_tk_prefix}/lib/tclConfig.sh",
        f"--with-tk-config={tcl_tk_prefix}/lib/tkConfig.sh",
        "--with-static-cairo=no",
        "--with-x",
        "--without-recommended-packages",
    ]
    if sys.platform != "darwin":
        bzip2 = shutil.which("bzip2") or "bzip2"
        conf_args.append(f"R_BZIPCMD={bzip2}")
    if sys.platform == "darwin":
        texbin = "/Library/TeX/texbin"
        if os.path.isdir(texbin):
            subprocess_env["PATH"] = texbin + ":" + subprocess_env.get("PATH", "")
        conf_args.append("--without-aqua")
    if is_devel:
        conf_args.append("--program-suffix=dev")
    if is_devel:
        svn = locate("svn")
        rtop = os.path.join(os.getcwd(), "svn", "r")
        os.makedirs(rtop, exist_ok=True)
        svn_url = "https://svn.r-project.org/R/trunk"
        subprocess.run(
            [
                svn,
                "--non-interactive",
                "--trust-server-cert-failures=unknown-ca,cn-mismatch,expired,not-yet-valid,other",
                "checkout",
                f"--revision={version}",
                svn_url,
                rtop,
            ],
            check=True,
        )
        os.chdir(rtop)
        with open("SVNINFO", "w") as fh:
            fh.write(f"Revision: {version}\n")
    else:
        maj_ver = major_version(version)
        url = f"https://cloud.r-project.org/src/base/R-{maj_ver}/R-{version}.tar.gz"
        download_extract_cd(url)
    subprocess_env["r_cv_have_curl728"] = "yes"
    jobs = os.cpu_count() or 1
    subprocess.run(
        ["./configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
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
