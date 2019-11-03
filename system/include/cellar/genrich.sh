#!/usr/bin/env bash

_koopa_help "$@"
_koopa_assert_has_no_args "$@"



# Variables                                                                 {{{1
# ==============================================================================

name="genrich"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"



# Script                                                                    {{{1
# ==============================================================================

_koopa_message "Installing ${name} ${version}."

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/jsh58/Genrich/archive/v${version}.tar.gz"
    _koopa_extract "v${version}.tar.gz"
    cd "Genrich-${version}" || exit 1
    make
    mkdir -pv "${prefix}/bin"
    cp -frv Genrich "${prefix}/bin/."
    rm -rf "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
