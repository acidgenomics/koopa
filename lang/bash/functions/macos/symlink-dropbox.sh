#!/usr/bin/env bash

_koopa_macos_symlink_dropbox() {
    # """
    # Symlink Dropbox.
    # @note Updated 2023-05-01.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_rm --sudo "${HOME}/Desktop"
    _koopa_ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    _koopa_rm --sudo "${HOME}/Documents"
    _koopa_ln "${HOME}/Dropbox/Documents" "${HOME}/."
    _koopa_sudo "${app['kill_all']}" 'Finder'
    return 0
}
