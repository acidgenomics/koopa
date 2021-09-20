#!/usr/bin/env bash

koopa::install_rmate() { # {{{1
    koopa:::install_app \
        --name='rmate' \
        "$@"
}

koopa:::install_rmate() { # {{{1
    # """
    # Install rmate.
    # @note Updated 2021-05-05.
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
    koopa::chmod 'a+x' "$name"
    koopa::mkdir "${prefix}/bin"
    koopa::cp --target="${prefix}/bin" "$name"
    return 0
}

koopa::uninstall_rmate() { # {{{1
    koopa:::uninstall_app \
        --name='rmate' \
        "$@"
}
