#!/usr/bin/env bash

install_automake() { # {{{1
    # """
    # Install automake.
    # @note Updated 2021-04-29.
    # """
    local file gnu_mirror jobs prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    file="automake-${version}.tar.xz"
    url="${gnu_mirror}/automake/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "automake-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_automake "$@"
