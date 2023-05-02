#!/usr/bin/env bash

koopa_linux_add_user_to_group() {
    # """
    # Add user to group.
    # @note Updated 2023-05-01.
    #
    # Alternate approach:
    # > koopa_sudo "${app['usermod']}" -a -G <GROUP> <USER>
    #
    # @examples
    # > koopa_linux_add_user_to_group 'docker'
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(koopa_linux_locate_gpasswd)"
    koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(koopa_user_name)"
    koopa_alert "Adding user '${dict['user']}' to group '${dict['group']}'."
    koopa_sudo \
        "${app['gpasswd']}" \
            --add "${dict['user']}" "${dict['group']}"
    return 0
}
