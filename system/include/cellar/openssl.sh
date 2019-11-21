#!/usr/bin/env bash
set -Eeu -o pipefail

name="openssl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    _koopa_download "https://www.openssl.org/source/openssl-${version}.tar.gz"
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
    make --jobs="$jobs"
    make test
    make install
    rm -fr "$tmp_dir"
)

# Keep this cellar only.

"$exe_file" version
command -v "$exe_file"
