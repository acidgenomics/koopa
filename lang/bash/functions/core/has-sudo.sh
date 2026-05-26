#!/usr/bin/env bash

_koopa_has_sudo() {
    # """
    # Check if sudo is available for the current user.
    # @note Updated 2026-05-26.
    #
    # Uses 'sudo -v -n' which reliably distinguishes between "user has sudo
    # but needs a password" vs "user is not permitted to run sudo at all"
    # on corporate-managed macOS (where 'sudo -n true' is unreliable).
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    local -A app
    local stderr
    _koopa_assert_has_no_args "$#"
    app['sudo']="$(_koopa_locate_sudo --allow-missing)"
    [[ -x "${app['sudo']}" ]] || return 1
    _koopa_is_root && return 0
    stderr="$("${app['sudo']}" -v -n 2>&1)"
    [[ $? -eq 0 ]] && return 0
    [[ "${stderr}" == *'password is required'* ]] && return 0
    return 1
}
