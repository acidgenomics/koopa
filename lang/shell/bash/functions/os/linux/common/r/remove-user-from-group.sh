#!/usr/bin/env bash

koopa_linux_remove_user_from_group() {
    # """
    # Remove user from group.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_linux_remove_user_from_group 'docker'
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 2
    koopa_assert_is_admin
    app['gpasswd']="$(koopa_linux_locate_gpasswd)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(koopa_user_name)"
    "${app['sudo']}" "${app['gpasswd']}" \
        --delete "${dict['user']}" "${dict['group']}"
    return 0
}
