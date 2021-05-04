#!/usr/bin/env bash

install_neofetch() { # {{{1
    # """
    # Install neofetch.
    # @note Updated 2021-04-27.
    # """
    local file name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='neofetch'
    file="${version}.tar.gz"
    url="https://github.com/dylanaraps/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::mkdir "$prefix"
    make PREFIX="$prefix" install
    return 0
}

install_neofetch "$@"
