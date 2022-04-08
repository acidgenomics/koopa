#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_dnf_remove \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    koopa_fedora_dnf_delete_repo 'winehq'
    return 0
}
