#!/usr/bin/env bash

koopa_is_owner() {
    # """
    # Does the current user own koopa?
    # @note Updated 2023-02-27.
    # """
    local dict
    declare -A dict
    dict['prefix']="$(koopa_koopa_prefix)"
    dict['owner_id']="$(koopa_stat_user "${dict['prefix']}")"
    dict['user_id']="$(koopa_user_id)"
    [[ "${dict['user_id']}" == "${dict['owner_id']}" ]]
}
