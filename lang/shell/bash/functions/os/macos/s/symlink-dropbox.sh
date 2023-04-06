#!/usr/bin/env bash

koopa_macos_symlink_dropbox() {
    # """
    # Symlink Dropbox.
    # @note Updated 2021-11-16.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['kill_all']="$(koopa_macos_locate_kill_all)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    koopa_rm --sudo "${HOME}/Desktop"
    koopa_ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    koopa_rm --sudo "${HOME}/Documents"
    koopa_ln "${HOME}/Dropbox/Documents" "${HOME}/."
    "${app['sudo']}" "${app['kill_all']}" 'Finder'
    return 0
}
