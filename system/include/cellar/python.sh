#!/usr/bin/env bash

# Install Python.
# Updated 2019-06-25.

# See also:
# - https://www.python.org/

_koopa_assert_has_no_environments

name="python"
version="$(_koopa_variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/python3"

printf "Installing %s %s.\n" "$name" "$version"

rm -rf "$tmp_dir"
mkdir "$tmp_dir"

# Ensure pip is installed and up to date.
# This step fails on RHEL8 because there's only python3, no python.
# > if _koopa_has_sudo
# > then
# >     (
# >         printf "Updating pip.\n"
# >         cd "$tmp_dir" || exit 1
# >         file="get-pip.py"
# >         url="https://bootstrap.pypa.io/${file}"
# >         wget "$url"
# >         sudo python "$file"
# >         sudo pip install -U pip
# >         # > sudo pip install -U virtualenv
# >     )
# > fi

# Ubuntu 18: This step fails unless `--without-ensurepip` flag is set.
# https://bugs.python.org/issue31652
# Seeing a `sharedinstall` error still.

(
    cd "$tmp_dir" || exit 1
    file="Python-${version}.tar.xz"
    url="https://www.python.org/ftp/python/${version}/${file}"
    wget "$url"
    tar xfv "Python-${version}.tar.xz"
    cd "Python-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-optimizations \
        --enable-shared \
        --without-ensurepip
    make --jobs="$CPU_COUNT"
    make install
)

rm -rf "$tmp_dir"
link-cellar "$name" "$version"

# Symlink python3 to python.
build_prefix="$(koopa build-prefix)"
ln -fns "${build_prefix}/bin/python3" "${build_prefix}/bin/python"

command -v "$exe_file"
"$exe_file" --version
