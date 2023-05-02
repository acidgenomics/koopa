#!/usr/bin/env bash

koopa_macos_brew_cask_quarantine_fix() {
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2023-05-01.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['xattr']="$(koopa_macos_locate_xattr)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo \
        "${app['xattr']}" -r -d \
            'com.apple.quarantine' \
            '/Applications/'*'.app'
    return 0
}
