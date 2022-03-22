#!/usr/bin/env bash

koopa_macos_symlink_dropbox() { # {{{1
    # """
    # Symlink Dropbox.
    # @note Updated 2021-11-16.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_rm --sudo "${HOME}/Desktop"
    koopa_ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    koopa_rm --sudo "${HOME}/Documents"
    koopa_ln "${HOME}/Dropbox/Documents" "${HOME}/."
    "${app[sudo]}" "${app[kill_all]}" 'Finder'
    return 0
}
