#!/usr/bin/env bash

install_groff() { # {{{1
    # """
    # Install groff.
    # @note Updated 2021-04-28.
    # """
    local file gnu_mirror jobs name prefix url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
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

install_groff "$@"
