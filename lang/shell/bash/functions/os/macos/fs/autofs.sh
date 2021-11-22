#!/usr/bin/env bash

koopa::macos_reload_autofs() { # {{{1
    # """
    # Reload autofs configuration defined in '/etc/auto_master'.
    # @note Updated 2021-10-27.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [automount]="$(koopa::macos_locate_automount)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[automount]}" -vc
    return 0
}
