#!/usr/bin/env bash

koopa_macos_brew_cask_quarantine_fix() {
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2021-10-27.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [xattr]="$(koopa_macos_locate_xattr)"
    )
    "${app[sudo]}" "${app[xattr]}" -r -d \
        'com.apple.quarantine' \
        '/Applications/'*'.app'
    return 0
}
