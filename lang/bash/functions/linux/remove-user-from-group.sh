#!/usr/bin/env bash

_koopa_linux_remove_user_from_group() {
    # """
    # Remove user from group.
    # @note Updated 2023-05-01.
    #
    # @examples
    # > _koopa_linux_remove_user_from_group 'docker'
    # """
    local -A app dict
    _koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(_koopa_linux_locate_gpasswd)"
    _koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(_koopa_user_name)"
    _koopa_sudo \
        "${app['gpasswd']}" \
            --delete "${dict['user']}" "${dict['group']}"
    return 0
}
