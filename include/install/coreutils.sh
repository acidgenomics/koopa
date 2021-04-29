#!/usr/bin/env bash

# FIXME USE SHARED FUNCTION FOR THIS.
install_coreutils() { # {{{1
    # """
    # Install GNU coreutils.
    # @note Updated 2021-04-29.
    # """
    local file gnu_mirror jobs prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    file="coreutils-${version}.tar.xz"
    url="${gnu_mirror}/coreutils/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "coreutils-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_coreutils "$@"
