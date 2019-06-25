#!/usr/bin/env bash

# Install htop.
# Modified 2019-06-25.

# See also:
# - https://hisham.hm/htop/releases/
# - https://github.com/hishamhm/htop

_koopa_assert_has_no_environments

name="htop"
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
    wget "https://hisham.hm/htop/releases/${version}/htop-${version}.tar.gz"
    tar -xzvf "htop-${version}.tar.gz"
    cd "htop-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make
    make check
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
