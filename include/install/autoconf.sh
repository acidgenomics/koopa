#!/usr/bin/env bash

# FIXME MAKE THIS A SHARED FUNCTION.
install_autoconf() { # {{{1
    # """
    # Install autoconf.
    # @note Updated 2021-04-29.
    # """
    local file gnu_mirror jobs prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    file="autoconf-${version}.tar.xz"
    url="${gnu_mirror}/autoconf/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "autoconf-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_autoconf "$@"
