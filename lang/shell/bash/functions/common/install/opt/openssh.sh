#!/usr/bin/env bash

koopa:::install_openssh() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2021-05-26.
    # """
    local file jobs make prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='openssh'
    file="${name}-${version}.tar.gz"
    url="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}
