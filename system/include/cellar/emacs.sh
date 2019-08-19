#!/usr/bin/env bash

# Install emacs.
# Updated 2019-06-25.

# See also:
# - https://www.gnu.org/software/emacs/
# - https://github.com/emacs-mirror/emacs

_koopa_assert_has_no_environments

name="emacs"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
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
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
