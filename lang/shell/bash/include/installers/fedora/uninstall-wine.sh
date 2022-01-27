#!/usr/bin/env bash

koopa:::fedora_uninstall_wine() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa::fedora_dnf_remove \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    koopa::fedora_dnf_delete_repo 'winehq'
    return 0
}
