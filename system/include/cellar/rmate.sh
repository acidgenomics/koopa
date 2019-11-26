#!/usr/bin/env bash
set -Eeu -o pipefail

name="rmate"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="v${version}.tar.gz"
    url="https://github.com/aurora/rmate/archive/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "rmate-${version}" || exit 1
    chmod a+x rmate
    mkdir -p "${prefix}/bin"
    cp rmate "${prefix}/bin"
)

_koopa_link_cellar "$name" "$version"
