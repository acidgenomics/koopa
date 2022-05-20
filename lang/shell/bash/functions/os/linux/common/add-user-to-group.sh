#!/usr/bin/env bash

koopa_linux_add_user_to_group() {
    # """
    # Add user to group.
    # @note Updated 2021-11-16.
    #
    # Alternate approach:
    # > "${app[usermod]}" -a -G group user
    #
    # @examples
    # > koopa_linux_add_user_to_group 'docker'
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
    koopa_alert "Adding user '${dict[user]}' to group '${dict[group]}'."
    "${app[sudo]}" "${app[gpasswd]}" --add "${dict[user]}" "${dict[group]}"
    return 0
}
