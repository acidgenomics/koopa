#!/usr/bin/env bash

# NOTE Seeing this pop up on macOS.
# # tar: Ignoring unknown extended header keyword

# FIXME Do we have to rethink our GOROOT config?

koopa::install_go() { # {{{1
    koopa::install_app \
        --name='go' \
        --name-fancy='Go' \
        "$@"
}

koopa:::install_go() { # {{{1
    # """
    # Install Go.
    # @note Updated 2021-05-05.
    # """
    local arch file name os_id prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='go'
    arch="$(koopa::arch2)"
    if koopa::is_macos
    then
        os_id='darwin'
    else
        os_id='linux'
    fi
    file="${name}${version}.${os_id}-${arch}.tar.gz"
    url="https://dl.google.com/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cp -t "$prefix" "${name}/"*
    return 0
}
