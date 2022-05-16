#!/usr/bin/env bash

koopa_has_passwordless_sudo() {
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2022-05-16.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_is_root && return 0
    koopa_is_installed 'sudo' || return 1
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[sudo]}" ]] || return 1
    "${app[sudo]}" -n true 2>/dev/null && return 0
    return 1
}
