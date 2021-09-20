#!/usr/bin/env bash

koopa::install_shunit2() { # {{{1
    koopa:::install_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa:::install_shunit2() { # {{{1
    # """
    # Install shUnit2.
    # @note Updated 2021-04-27.
    # """
    local file name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='shunit2'
    file="v${version}.tar.gz"
    url="https://github.com/kward/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::cp --target="${prefix}/bin" "$name"
    return 0
}

koopa::uninstall_shunit2() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}
