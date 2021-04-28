#!/usr/bin/env bash

install_openssl() { # {{{1
    # """
    # Install OpenSSL.
    # @note Updated 2021-04-28.
    # """
    local file name prefix url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://www.${name}.org/source/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
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
