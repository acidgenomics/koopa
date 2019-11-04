#!/usr/bin/env bash

_koopa_help "$@"
_koopa_assert_has_no_args "$@"

name="rmate"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/aurora/rmate/archive/v${version}.tar.gz"
    _koopa_extract "v${version}.tar.gz"
    cd "rmate-${version}" || exit 1
    chmod a+x rmate
    cp rmate "${prefix}/bin"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
