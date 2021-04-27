#!/usr/bin/env bash

install_binutils() { # {{{1
    # """
    # Install binutils.
    # @note Updated 2021-04-27.
    # """
    local file gnu_mirror jobs name prefix url version
    koopa::assert_is_installed makeinfo  # texinfo
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
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

install_binutils "$@"
