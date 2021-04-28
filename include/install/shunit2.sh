#!/usr/bin/env bash

install_shunit2() { # {{{1
    # """
    # Install shUnit2.
    # @note Updated 2021-04-27.
    # """
    local file name prefix url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file="v${version}.tar.gz"
    url="https://github.com/kward/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::cp -t "${prefix}/bin" "$name"
    return 0
}

install_shunit2 "$@"
