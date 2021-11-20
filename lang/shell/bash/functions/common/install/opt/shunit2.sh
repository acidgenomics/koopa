#!/usr/bin/env bash

koopa:::install_shunit2() { # {{{1
    # """
    # Install shUnit2.
    # @note Updated 2021-10-22.
    # """
    local file name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='shunit2'
    file="v${version}.tar.gz"
    url="https://github.com/kward/${name}/archive/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::cp --target-directory="${prefix}/bin" "$name"
    return 0
}
