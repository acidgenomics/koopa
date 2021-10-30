#!/usr/bin/env bash

koopa::macos_symlink_dropbox() { # {{{1
    # """
    # Symlink Dropbox.
    # @note Updated 2021-10-29.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa::locate_kill_all)"
        [sudo]="$(koopa::locate_sudo)"
    )
    koopa::rm --sudo "${HOME}/Desktop"
    koopa::ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    koopa::rm --sudo "${HOME}/Documents"
    koopa::ln "${HOME}/Dropbox/Documents" "${HOME}/."
    "${app[sudo]}" "${app[kill_all]}" 'Finder'
    return 0
}
