#!/usr/bin/env bash

main() {
    # """
    # Install jless.
    # @note Updated 2023-07-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/jless
    # """
    if koopa_is_linux
    then
        koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb'
    fi
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='jless'
}
