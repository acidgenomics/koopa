#!/usr/bin/env bash

main() {
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-27.
    # """
    koopa_fedora_dnf_remove \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    koopa_fedora_dnf_delete_repo 'winehq'
    return 0
}
