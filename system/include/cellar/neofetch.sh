#!/usr/bin/env bash
set -Eeu -o pipefail

name="neofetch"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="${version}.tar.gz"
    url="https://github.com/dylanaraps/${name}/archive/${file}"
    echo "$url"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "${name}-${version}" || exit 1
    mkdir -pv "$prefix"
    make PREFIX="$prefix" install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
