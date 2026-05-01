#!/usr/bin/env bash

_koopa_macos_brew_cask_quarantine_fix() {
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2023-05-01.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['xattr']="$(_koopa_macos_locate_xattr)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo \
        "${app['xattr']}" -r -d \
            'com.apple.quarantine' \
            '/Applications/'*'.app'
    return 0
}
