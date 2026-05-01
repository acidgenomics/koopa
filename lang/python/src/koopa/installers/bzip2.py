"""Install bzip2."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate, shared_ext
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd, remove_static_libs
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bzip2."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    ext = shared_ext()
    maj_min_ver = major_minor_version(version)
    os.makedirs(os.path.join(prefix, "lib"), exist_ok=True)
    url = f"https://sourceware.org/pub/bzip2/bzip2-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    makefile_shared = f"Makefile-libbz2_{ext}"
    if not os.path.exists(makefile_shared) and sys.platform == "darwin":
        with open(makefile_shared, "w") as fh:
            fh.write(f"""\
PKG_VERSION?={version}
PREFIX?={prefix}

SHELL=/bin/sh
CC=gcc
BIGFILES=-D_FILE_OFFSET_BITS=64
CFLAGS=-fpic -fPIC -Wall -Winline -O2 -g $(BIGFILES)

OBJS= blocksort.o  \\
      huffman.o    \\
      crctable.o   \\
      randtable.o  \\
      compress.o   \\
      decompress.o \\
      bzlib.o

all: $(OBJS)
\t$(CC) -shared -Wl,-install_name -Wl,libbz2.dylib -o libbz2.${{PKG_VERSION}}.dylib $(OBJS)
\tcp libbz2.${{PKG_VERSION}}.dylib ${{PREFIX}}/lib/
\tln -s libbz2.${{PKG_VERSION}}.dylib ${{PREFIX}}/lib/libbz2.dylib

clean:
\trm -f libbz2.dylib libbz2.${{PKG_VERSION}}.dylib

blocksort.o: blocksort.c
\t$(CC) $(CFLAGS) -c blocksort.c
huffman.o: huffman.c
\t$(CC) $(CFLAGS) -c huffman.c
crctable.o: crctable.c
\t$(CC) $(CFLAGS) -c crctable.c
randtable.o: randtable.c
\t$(CC) $(CFLAGS) -c randtable.c
compress.o: compress.c
\t$(CC) $(CFLAGS) -c compress.c
decompress.o: decompress.c
\t$(CC) $(CFLAGS) -c decompress.c
bzlib.o: bzlib.c
\t$(CC) $(CFLAGS) -c bzlib.c
""")
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=subprocess_env,
        check=True,
    )
    if os.path.exists(makefile_shared):
        subprocess.run(
            [make, "-f", makefile_shared, "clean"],
            env=subprocess_env,
            check=True,
        )
        subprocess.run(
            [make, "-f", makefile_shared],
            env=subprocess_env,
            check=True,
        )
    lib_dir = os.path.join(prefix, "lib")
    if sys.platform != "darwin":
        real_lib = f"libbz2.{ext}.{version}"
        if os.path.exists(real_lib):
            dst_path = os.path.join(lib_dir, real_lib)
            with open(real_lib, "rb") as src_fh, open(dst_path, "wb") as dst_fh:
                dst_fh.write(src_fh.read())
        ln(
            f"libbz2.{ext}.{version}",
            os.path.join(lib_dir, f"libbz2.{ext}.{maj_min_ver}"),
        )
        ln(
            f"libbz2.{ext}.{version}",
            os.path.join(lib_dir, f"libbz2.{ext}"),
        )
    else:
        real_lib = f"libbz2.{version}.{ext}"
        if os.path.exists(real_lib):
            dst_path = os.path.join(lib_dir, real_lib)
            with open(real_lib, "rb") as src_fh, open(dst_path, "wb") as dst_fh:
                dst_fh.write(src_fh.read())
        ln(
            f"libbz2.{version}.{ext}",
            os.path.join(lib_dir, f"libbz2.{maj_min_ver}.{ext}"),
        )
        ln(
            f"libbz2.{version}.{ext}",
            os.path.join(lib_dir, f"libbz2.{ext}"),
        )
    remove_static_libs(prefix)
    pkg_config_dir = os.path.join(prefix, "lib", "pkgconfig")
    pkg_config_file = os.path.join(pkg_config_dir, "bzip2.pc")
    if not os.path.exists(pkg_config_file):
        os.makedirs(pkg_config_dir, exist_ok=True)
        with open(pkg_config_file, "w") as fh:
            fh.write(f"""\
prefix={prefix}
exec_prefix=${{prefix}}
bindir=${{exec_prefix}}/bin
libdir=${{exec_prefix}}/lib
includedir=${{prefix}}/include

Name: bzip2
Description: Lossless, block-sorting data compression
Version: {version}
Libs: -L${{libdir}} -lbz2
Cflags: -I${{includedir}}
""")
