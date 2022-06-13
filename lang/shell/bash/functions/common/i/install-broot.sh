#!/usr/bin/env bash

koopa_install_broot() {
    # """
    # Consider including opt (used in Homebrew recipe):
    # - xorg-xorgproto
    # - xorg-xcb-proto
    # - xorg-libpthread-stubs
    # - xorg-libxau
    # - xorg-libxau
    # - xorg-libxdmcp
    # - 'xorg-libxcb'
    #
    # @seealso
    # - https://dystroy.org/broot/install/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/broot.rb
    # """
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/broot' \
        --name='broot' \
        "$@"
}
