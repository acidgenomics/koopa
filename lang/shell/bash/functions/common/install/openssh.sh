#!/usr/bin/env bash

koopa::install_openssh() { # {{{1
    koopa::install_app \
        --name='openssh' \
        --name-fancy='OpenSSH' \
        "$@"
}

koopa:::install_openssh() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2021-05-04.
    # """
    local file jobs prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='openssh'
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}
