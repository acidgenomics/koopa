#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_password_store() { # {{{1
    koopa::install_app \
        --name='password-store' \
        "$@"
}

koopa:::install_password_store() { # {{{1
    # """
    # Install Password Store.
    # @note Updated 2021-05-04.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local file prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='password-store'
    file="${name}-${version}.tar.xz"
    url="https://git.zx2c4.com/${name}/snapshot/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    PREFIX="$prefix" make install
    return 0
}
