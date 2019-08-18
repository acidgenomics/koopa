#!/usr/bin/env bash

# Install Git SCM.
# Updated 2019-07-09.

# The compilation settings here are from the Git SCM book website.
# Refer also to INSTALL file for details.

# This currently fails if OpenSSL v1.1.1+ is installed to `/usr/local`.
# Instead, compile Git to use the system OpenSSL in `/bin/`.

# See also:
# - https://git-scm.com/
# - https://github.com/git/git
# - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
# - https://github.com/git/git/blob/master/INSTALL
# - https://github.com/progit/progit2/blob/master/book/01-introduction/sections/installing.asc

_koopa_assert_has_no_environments
_koopa_assert_is_installed docbook2x-texi

name="git"
version="$(_koopa_variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/git/git/archive/v${version}.tar.gz"
    tar -zxf "v${version}.tar.gz"
    cd "git-${version}" || exit 1
    make configure
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --with-openssl="/bin/openssl"
    # This is now erroring on RHEL 7.7:
    # > make --jobs="$CPU_COUNT" all doc info
    # > make install install-doc install-html install-info
    make --jobs="$CPU_COUNT"
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
