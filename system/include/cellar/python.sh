#!/usr/bin/env bash

# Install Python.
# Modified 2019-06-23.

# See also:
# - https://www.python.org/

name="python"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/python3"

printf "Installing %s %s.\n" "$name" "$version"

rm -rf "$tmp_dir"
mkdir "$tmp_dir"

# Ensure pip is installed and up to date.
if _koopa_has_sudo
then
    printf "Updating pip.\n"
    (
        cd "$tmp_dir"
        wget https://bootstrap.pypa.io/get-pip.py
        sudo python get-pip.py
        sudo pip install -U pip
        # > sudo pip install -U virtualenv
    )
fi

(
    cd "$tmp_dir"
    wget "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz"
    tar xfv "Python-${version}.tar.xz"
    cd "Python-${version}"
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-optimizations \
        --enable-shared
    make
    make install
)

rm -rf "$tmp_dir"
link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
