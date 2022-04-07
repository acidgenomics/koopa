#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_fedora_dnf_remove \
        'winehq-stable' \
        'xorg-x11-apps' \
        'xorg-x11-server-Xvfb' \
        'xorg-x11-xauth'
    koopa_fedora_dnf_delete_repo 'winehq'
    return 0
}
