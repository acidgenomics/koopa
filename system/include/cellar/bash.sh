#!/usr/bin/env bash

## Install Bash.
## Updated 2019-06-26.

## See also:
## - https://www.gnu.org/software/bash/

_koopa_assert_has_no_environments

name="bash"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
gnu_mirror="http://ftpmirror.gnu.org"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "${gnu_mirror}/bash/bash-${version}.tar.gz"
    tar -xzvf "bash-${version}.tar.gz"
    cd "bash-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make test
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"
_koopa_update_shells "$name"

"$exe_file" --version
command -v "$exe_file"
