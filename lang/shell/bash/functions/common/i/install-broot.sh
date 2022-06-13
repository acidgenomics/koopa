#!/usr/bin/env bash

koopa_install_broot() {
    # """
    # @seealso
    # - https://dystroy.org/broot/install/
    # """
    koopa_install_app \
        --activate-opt='xorg-xorgproto' \
        --activate-opt='xorg-xcb-proto' \
        --activate-opt='xorg-libpthread-stubs' \
        --activate-opt='xorg-libxau' \
        --activate-opt='xorg-libxau' \
        --activate-opt='xorg-libxdmcp' \
        --activate-opt='xorg-libxcb' \
        --installer='rust-package' \
        --link-in-bin='bin/broot' \
        --name='broot' \
        "$@"
}
