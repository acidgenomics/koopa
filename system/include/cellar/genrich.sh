#!/usr/bin/env bash
set -Eeu -o pipefail

name="genrich"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="v${version}.tar.gz"
    _koopa_download "https://github.com/jsh58/Genrich/archive/${file}"
    _koopa_extract "$file"
    cd "Genrich-${version}" || exit 1
    make
    mkdir -pv "${prefix}/bin"
    cp -frv Genrich "${prefix}/bin/."
    rm -rf "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
