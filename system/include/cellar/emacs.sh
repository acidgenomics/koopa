#!/usr/bin/env bash

# Install emacs.
# Updated 2019-06-23.

# See also:
# - https://www.gnu.org/software/emacs/
# - https://github.com/emacs-mirror/emacs

name="emacs"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "http://ftp.gnu.org/gnu/emacs/emacs-${version}.tar.xz"
    tar -xJvf "emacs-${version}.tar.xz"
    cd "emacs-${version}" || exit 1
    ./configure \
        --build="$build_os_string"
        --prefix="$prefix"
    make
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
