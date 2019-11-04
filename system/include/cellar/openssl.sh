#!/usr/bin/env bash

_koopa_help "$@"
_koopa_assert_has_no_args "$@"

name="openssl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    curl -O "https://www.openssl.org/source/openssl-${version}.tar.gz"
    _koopa_extract "openssl-${version}.tar.gz"
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
