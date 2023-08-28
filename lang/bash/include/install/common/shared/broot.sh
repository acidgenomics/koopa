#!/usr/bin/env bash

main() {
    # """
    # Install broot.
    # @note Updated 2023-08-28.
    #
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
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='broot'
}
