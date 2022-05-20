#!/usr/bin/env bash

koopa_linux_remove_user_from_group() {
    # """
    # Remove user from group.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_linux_remove_user_from_group 'docker'
    # """
    local app dict
    koopa_assert_has_args_le "$#" 2
    koopa_assert_is_admin
    declare -A app=(
        [gpasswd]="$(koopa_linux_locate_gpasswd)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [group]="${1:?}"
        [user]="${2:-}"
    )
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa_user)"
    "${app[sudo]}" "${app[gpasswd]}" --delete "${dict[user]}" "${dict[group]}"
    return 0
}
