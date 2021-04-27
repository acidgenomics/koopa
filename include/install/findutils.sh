#!/usr/bin/env bash

install_findutils() { # {{{1
    # """
    # Install findutils.
    # @note Updated 2021-04-27.
    # """
    local file gnu_mirror jobs name prefix url version
    gnu_mirror="${INSTALL_GNU_MIRROR:?}"
    jobs="${INSTALL_JOBS:?}"
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
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

install_findutils "$@"
