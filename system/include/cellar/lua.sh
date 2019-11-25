#!/usr/bin/env bash
set -Eeu -o pipefail

name="lua"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="${name}-${version}.tar.gz"
    curl -R -O "http://www.lua.org/ftp/${file}"
    _koopa_extract "$file"
    cd "${name}-${version}" || exit 1
    if _koopa_is_darwin
    then
        make macosx test
    else
        make linux test
    fi
    make install INSTALL_TOP="$prefix"
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
