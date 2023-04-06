#!/usr/bin/env bash

koopa_has_passwordless_sudo() {
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2023-04-05.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['sudo']="$(koopa_locate_sudo --allow-missing)"
    [[ -x "${app['sudo']}" ]] || return 1
    koopa_is_root && return 0
    "${app['sudo']}" -n true 2>/dev/null && return 0
    return 1
}
