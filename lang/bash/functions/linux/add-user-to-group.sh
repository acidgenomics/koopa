#!/usr/bin/env bash

_koopa_linux_add_user_to_group() {
    # """
    # Add user to group.
    # @note Updated 2023-05-01.
    #
    # Alternate approach:
    # > _koopa_sudo "${app['usermod']}" -a -G <GROUP> <USER>
    #
    # @examples
    # > _koopa_linux_add_user_to_group 'docker'
    # """
    local -A app dict
    _koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(_koopa_linux_locate_gpasswd)"
    _koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(_koopa_user_name)"
    _koopa_alert "Adding user '${dict['user']}' to group '${dict['group']}'."
    _koopa_sudo \
        "${app['gpasswd']}" \
            --add "${dict['user']}" "${dict['group']}"
    return 0
}
