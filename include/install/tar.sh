#!/usr/bin/env bash

install_tar() { # {{{1
    # """
    # Install GNU tar.
    # @note Updated  2021-04-27.
    # """
    local file jobs name prefix url version
    koopa::assert_is_installed gcc tar
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    ## Note that xz file is also available.
    file="${name}-${version}.tar.gz"
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

install_tar "$@"
