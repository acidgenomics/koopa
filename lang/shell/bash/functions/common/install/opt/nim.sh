#!/usr/bin/env bash

koopa::configure_nim() {
    # """
    # Configure Nim.
    # @note Updated 2021-09-29.
    # """
    local nim
    nim="$(koopa::locate_nim)"
    koopa:::configure_app_packages \
        --name='nim' \
        --name-fancy='Nim' \
        --which-app="$nim"
    return 0
}

# FIXME Need to be able to install nim from source.
# FIXME Need to work out how to configure nimble and nim packages.
# FIXME Need to add support inside of koopa for this -- 'nim-packages'.
# FIXME Need to add uninstall support.
