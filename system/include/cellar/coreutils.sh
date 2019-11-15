#!/usr/bin/env bash

name="coreutils"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
exe_file="${prefix}/bin/env"

_koopa_message "Installing ${name} ${version}."

(
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="coreutils-${version}.tar.xz"
    url="https://ftp.gnu.org/gnu/coreutils/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "coreutils-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    # > make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
