#!/usr/bin/env bash

koopa:::install_password_store() { # {{{1
    # """
    # Install Password Store.
    # @note Updated 2021-09-30.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local file make prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    make="$(koopa::locate_make)"
    name='password-store'
    file="${name}-${version}.tar.xz"
    url="https://git.zx2c4.com/${name}/snapshot/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    PREFIX="$prefix" "$make" install
    return 0
}
