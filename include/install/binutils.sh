#!/usr/bin/env bash

# FIXME MAKE THIS A SHARED FUNCTION.
install_binutils() { # {{{1
    # """
    # Install binutils.
    # @note Updated 2021-04-29.
    # """
    local file gnu_mirror jobs prefix url version
    koopa::assert_is_installed makeinfo  # texinfo
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    file="binutils-${version}.tar.xz"
    url="${gnu_mirror}/binutils/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "binutils-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_binutils "$@"
