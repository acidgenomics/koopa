#!/usr/bin/env bash
set -Eeu -o pipefail

name="lua"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
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

"$exe_file" -v
command -v "$exe_file"
