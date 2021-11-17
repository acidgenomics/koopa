#!/usr/bin/env bash

koopa:::install_go() { # {{{1
    # """
    # Install Go.
    # @note Updated 2021-10-22.
    # """
    local arch file name os_id prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='go'
    # e.g. 'amd64' for x86.
    arch="$(koopa::arch2)"
    if koopa::is_macos
    then
        os_id='darwin'
    else
        os_id='linux'
    fi
    file="${name}${version}.${os_id}-${arch}.tar.gz"
    url="https://dl.google.com/${name}/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cp --target-directory="$prefix" "${name}/"*
    return 0
}
