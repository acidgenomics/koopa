"""Install ncurses."""

from __future__ import annotations

import os
import sys
from glob import glob

from koopa.build import shared_ext
from koopa.file_ops import ln
from koopa.install import install_gnu_app
from koopa.version import major_minor_version, major_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ncurses."""
    ext = shared_ext()
    maj_ver = major_version(version)
    maj_min_ver = major_minor_version(version)
    pkgconfig_dir = os.path.join(prefix, "lib", "pkgconfig")
    os.makedirs(pkgconfig_dir, exist_ok=True)
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        conf_args=[
            "--enable-pc-files",
            "--enable-sigwinch",
            "--enable-symlinks",
            "--enable-widec",
            "--with-cxx-binding",
            "--with-cxx-shared",
            "--with-gpm=no",
            "--with-manpage-format=normal",
            f"--with-pkg-config-libdir={pkgconfig_dir}",
            "--with-shared",
            "--with-versioned-syms",
            "--without-ada",
        ],
    )
    bin_dir = os.path.join(prefix, "bin")
    ln(
        f"ncursesw{maj_ver}-config",
        os.path.join(bin_dir, f"ncurses{maj_ver}-config"),
    )
    inc_dir = os.path.join(prefix, "include")
    ln("ncursesw", os.path.join(inc_dir, "ncurses"))
    for h in ("curses", "form", "ncurses", "panel", "term", "termcap"):
        ln(f"ncursesw/{h}.h", os.path.join(inc_dir, f"{h}.h"))
    lib_dir = os.path.join(prefix, "lib")
    for f in glob(os.path.join(lib_dir, "*.a")):
        os.unlink(f)
    lib_names = ("libform", "libmenu", "libncurses", "libncurses++", "libpanel")
    for lib in lib_names:
        ln(f"{lib}w.{ext}", os.path.join(lib_dir, f"{lib}.{ext}"))
        if sys.platform != "darwin":
            ln(
                f"{lib}w.{ext}.{maj_ver}",
                os.path.join(lib_dir, f"{lib}.{ext}.{maj_ver}"),
            )
            ln(
                f"{lib}w.{ext}.{maj_min_ver}",
                os.path.join(lib_dir, f"{lib}.{ext}.{maj_min_ver}"),
            )
        else:
            ln(
                f"{lib}w.{maj_ver}.{ext}",
                os.path.join(lib_dir, f"{lib}.{maj_ver}.{ext}"),
            )
    ln(f"libncurses.{ext}", os.path.join(lib_dir, f"libcurses.{ext}"))
    ln(f"libncurses.{ext}", os.path.join(lib_dir, f"libtermcap.{ext}"))
    ln(f"libncurses.{ext}", os.path.join(lib_dir, f"libtinfo.{ext}"))
    pc_dir = os.path.join(prefix, "lib", "pkgconfig")
    for pc in ("form", "menu", "ncurses++", "ncurses", "panel"):
        ln(f"{pc}w.pc", os.path.join(pc_dir, f"{pc}.pc"))
    if sys.platform == "darwin":
        man_dir = os.path.join(prefix, "share", "man", "man1")
        if os.path.isdir(man_dir):
            for m in ("captoinfo", "infocmp", "infotocap", "tic", "toe"):
                src = os.path.join(man_dir, f"{m}.1m")
                if os.path.exists(src):
                    ln(f"{m}.1m", os.path.join(man_dir, f"{m}.1"))
