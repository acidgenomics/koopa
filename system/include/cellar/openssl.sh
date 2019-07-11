#!/usr/bin/env bash

# Install OpenSSL.
# Modified 2019-07-10.

# Currently installing as cellar-only.
# This is useful for running RDAVIDWebService but can break other programs
# when installed into `/usr/local`.

# See also:
# - https://www.openssl.org/source/
# - https://wiki.openssl.org/index.php/Compilation_and_Installation
# - https://wiki.openssl.org/index.php/Binary_Compatibility

_koopa_assert_has_no_environments

name="openssl"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
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
    make
    make test
    make install
    rm -rf "$tmp_dir"
)

"$exe_file" version
command -v "$exe_file"
