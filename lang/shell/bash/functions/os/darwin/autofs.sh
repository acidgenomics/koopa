#!/usr/bin/env bash

koopa::macos_reload_autofs() { # {{{1
    # """
    # Reload autofs configuration defined in '/etc/auto_master'.
    # @note Updated 2021-05-08.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    sudo automount -vc
    return 0
}
