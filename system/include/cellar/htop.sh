#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-htop [--help|-h]

Install htop.

see also:
    - https://hisham.hm/htop/releases/
    - https://github.com/hishamhm/htop

note:
    Bash script.
    Updated 2019-09-17.
EOF
}

_koopa_help "$@"

_koopa_assert_is_installed python

name="htop"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://hisham.hm/htop/releases/${version}/htop-${version}.tar.gz"
    tar -xzvf "htop-${version}.tar.gz"
    cd "htop-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
