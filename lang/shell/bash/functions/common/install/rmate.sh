#!/usr/bin/env bash

koopa::install_rmate() { # {{{1
    koopa::install_app \
        --name='rmate' \
        "$@"
}

koopa:::install_rmate() { # {{{1
    # """
    # Install rmate.
    # @note Updated 2021-04-27.
    # """
    local file name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='rmate'
    file="v${version}.tar.gz"
    url="https://github.com/aurora/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    chmod a+x rmate
    koopa::mkdir "${prefix}/bin"
    koopa::cp -t "${prefix}/bin" 'rmate'
    return 0
}
