#!/usr/bin/env bash

koopa:::install_neofetch() { # {{{1
    # """
    # Install neofetch.
    # @note Updated 2021-05-26.
    # """
    local file make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    make="$(koopa::locate_make)"
    name='neofetch'
    file="${version}.tar.gz"
    url="https://github.com/dylanaraps/${name}/archive/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::mkdir "$prefix"
    "$make" PREFIX="$prefix" install
    return 0
}
