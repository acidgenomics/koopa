#!/usr/bin/env bash

# Install PROJ.
# Updated 2019-07-26.

# See also:
# - https://proj.org/
# - https://github.com/OSGeo/PROJ/

_koopa_assert_has_no_environments

name="proj"
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
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/PROJ/releases/download/${version}/${file}"
    wget "$url"
    tar -xzvf "$file"
    cd "${name}-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

"$exe_file"
command -v "$exe_file"
