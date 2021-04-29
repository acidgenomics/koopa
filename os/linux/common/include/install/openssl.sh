#!/usr/bin/env bash

install_openssl() { # {{{1
    # """
    # Install OpenSSL.
    # @note Updated 2021-04-29.
    # """
    local file prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="openssl-${version}.tar.gz"
    url="https://www.openssl.org/source/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "openssl-${version}"
    ./config \
        --prefix="$prefix" \
        --openssldir="$prefix" \
        shared
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}

install_openssl "$@"
