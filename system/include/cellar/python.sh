#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-python [--help|-h]

Install Python.

see also:
    - https://www.python.org/

note:
    Bash script.
    Updated 2019-09-17.
EOF
}

_koopa_help "$@"

name="python"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/python3"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="Python-${version}.tar.xz"
    url="https://www.python.org/ftp/python/${version}/${file}"
    wget "$url"
    tar xfv "Python-${version}.tar.xz"
    cd "Python-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-optimizations \
        --enable-shared \
        --without-ensurepip
    make --jobs="$CPU_COUNT"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

# Symlink python3 to python.
build_prefix="$(_koopa_build_prefix)"
ln -fns "${build_prefix}/bin/python3" "${build_prefix}/bin/python"

command -v "$exe_file"
"$exe_file" --version
