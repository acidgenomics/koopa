#!/usr/bin/env bash

koopa_macos_brew_cask_quarantine_fix() {
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2021-10-27.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['sudo']="$(koopa_locate_sudo)"
    app['xattr']="$(koopa_macos_locate_xattr)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['xattr']}" -r -d \
        'com.apple.quarantine' \
        '/Applications/'*'.app'
    return 0
}
