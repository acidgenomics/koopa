#!/usr/bin/env bash

install_password_store() { # {{{1
    # """
    # Install Password Store.
    # @note Updated 2021-04-29.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local file prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file="password-store-${version}.tar.xz"
    url="https://git.zx2c4.com/password-store/snapshot/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "password-store-${version}"
    PREFIX="$prefix" make install
    return 0
}

install_password_store "$@"
