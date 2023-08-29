#!/usr/bin/env bash

main() {
    # """
    # Install jless.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/jless
    # """
    local -A dict
    if koopa_is_linux
    then
        koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb'
    fi
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_rust_package \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --version="${dict['version']}"
    return 0
}
