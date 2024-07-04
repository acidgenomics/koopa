#!/usr/bin/env bash

koopa_admin_group_id() {
    # """
    # Return the administrator group identifier.
    # @note Updated 2024-06-27.
    #
    # @seealso
    # - https://stackoverflow.com/questions/29357095/
    # """
    local -A app dict
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['group_name']="$(koopa_admin_group_name)"
    dict['group_id']="$( \
        koopa_getent 'group' "${dict['group_name']}" \
        | "${app['cut']}" -d ':' -f 3 \
    )"
    [[ -n "${dict['group_id']}" ]] || return 1
    koopa_print "${dict['group_id']}"
    return 0
}
