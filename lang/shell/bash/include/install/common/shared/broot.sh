#!/usr/bin/env bash

main() {
    # """
    # Consider including opt (used in Homebrew recipe):
    # - 'xorg-xorgproto'
    # - 'xorg-xcb-proto'
    # - 'xorg-libpthread-stubs'
    # - 'xorg-libxau'
    # - 'xorg-libxau'
    # - 'xorg-libxdmcp'
    # - 'xorg-libxcb'
    #
    # @seealso
    # - https://dystroy.org/broot/install/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/broot.rb
    # """
    koopa_install_app_internal \
        --installer='rust-package' \
        --name='broot' \
        "$@"
}
