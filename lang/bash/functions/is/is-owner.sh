#!/usr/bin/env bash

_koopa_is_owner() {
    # """
    # Does the current user own koopa?
    # @note Updated 2023-03-26.
    # """
    local -A dict
    dict['prefix']="$(_koopa_koopa_prefix)"
    dict['owner_id']="$(_koopa_stat_user_id "${dict['prefix']}")"
    dict['user_id']="$(_koopa_user_id)"
    [[ "${dict['user_id']}" == "${dict['owner_id']}" ]]
}
