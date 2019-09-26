#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-neofetch [--help|-h]

Install Neofetch.

see also:
    - https://github.com/dylanaraps/neofetch/wiki/Installation

note:
    Bash script.
    Updated 2019-09-23.
EOF
}

_koopa_help "$@"

name="neofetch"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/dylanaraps/${name}/archive/${version}.tar.gz"
    tar -xzvf "${version}.tar.gz"
    cd "${name}-${version}" || exit 1
    mkdir -pv "$prefix"
    make PREFIX="$prefix" install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
