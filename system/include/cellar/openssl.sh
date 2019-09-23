#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-openssl [--help|-h]

Install (cellar-only) OpenSSL.

details:
    Currently installing as cellar-only.

    This is useful for running RDAVIDWebService on a virtual machine but can
    break other programs when installed into '/usr/local'.

    Alternatively, can consider using OpenSSL available via conda.

see also:
    - https://www.openssl.org/source/
    - https://wiki.openssl.org/index.php/Compilation_and_Installation
    - https://wiki.openssl.org/index.php/Binary_Compatibility

note:
    Bash script.
    Updated 2019-09-23.
EOF
}

_koopa_help "$@"

name="openssl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    curl -O "https://www.openssl.org/source/openssl-${version}.tar.gz"
    tar -xvzf "openssl-${version}.tar.gz"
    cd "openssl-${version}" || exit 1
    if _koopa_is_darwin
    then
        ./Configure \
            darwin64-x86_64-cc \
            --prefix="$prefix" \
            --openssldir="$prefix"
    else
        ./config \
            --prefix="$prefix" \
            --openssldir="$prefix" \
            shared
    fi
    make --jobs="$CPU_COUNT"
    make test
    make install
    rm -fr "$tmp_dir"
)

"$exe_file" version
command -v "$exe_file"
