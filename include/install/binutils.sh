#!/usr/bin/env bash

install_binutils() { # {{{1
    # """
    # Install binutils.
    # @note Updated 2021-04-26.
    # """
    local file gnu_mirror jobs name prefix url version
    koopa::assert_is_installed makeinfo  # texinfo
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

install_binutils "$@"
