#!/usr/bin/env bash

_koopa_check_disk() {
    # """
    # Check that disk has enough free space.
    # @note Updated 2022-01-21.
    # """
    local -A dict
    _koopa_assert_has_args "$#"
    dict['limit']=90
    dict['used']="$(_koopa_disk_pct_used "$@")"
    if [[ "${dict['used']}" -gt "${dict['limit']}" ]]
    then
        _koopa_warn "Disk usage is ${dict['used']}%."
        return 1
    fi
    return 0
}
