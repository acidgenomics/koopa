#!/usr/bin/env bash

main() {
    # """
    # Install broot.
    # @note Updated 2023-08-28.
    #
    # How to install from git when crates.io is outdated:
    # > -D '--git' -D 'https://github.com/Canop/broot.git'
    # > -D '--tag' -D "v${KOOPA_INSTALL_VERSION:?}"
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
