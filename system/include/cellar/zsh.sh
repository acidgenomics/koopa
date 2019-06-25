#!/usr/bin/env bash

# Install Z shell.
# Modified 2019-06-25.

# See also:
# - http://www.zsh.org/
# - http://zsh.sourceforge.net/Arc/source.html
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH

_koopa_assert_has_no_environments

name="zsh"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/zsh"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://sourceforge.net/projects/zsh/files/zsh/${version}/zsh-${version}.tar.xz/download"
    tar -xJvf "download"
    cd "zsh-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make
    make check
    make test
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"
_koopa_update_shells "$name"

command -v "$exe_file"
"$exe_file" --version
