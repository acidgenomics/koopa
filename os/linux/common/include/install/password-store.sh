#!/usr/bin/env bash

install_password_store() { # {{{1
    # """
    # Install Password Store.
    # @note Updated 2021-04-28.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local file name prefix url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file="${name}-${version}.tar.xz"
    url="https://git.zx2c4.com/${name}/snapshot/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    PREFIX="$prefix" make install
    return 0
}

install_password_store "$@"
