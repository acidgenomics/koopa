#!/usr/bin/env bash

install_sed() { # {{{1
    # """
    # Install sed.
    # @note Updated 2021-04-27.
    # """
    local file jobs name prefix url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.xz"
    url="${gnu_mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_sed "$@"
