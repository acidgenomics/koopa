#!/usr/bin/env bash

main() {
    # """
    # Install jless.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/jless
    # """
    if _koopa_is_linux
    then
        _koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb'
    fi
    _koopa_install_rust_package
    return 0
}
