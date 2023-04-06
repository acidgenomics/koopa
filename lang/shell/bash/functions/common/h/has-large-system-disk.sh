#!/usr/bin/env bash

koopa_has_large_system_disk() {
    # """
    # Is the current environment running with a large system disk?
    # @note Updated 2022-12-05.
    #
    # Can manually override with 'KOOPA_BUIDLER' variable.
    # """
    local -A dict
    koopa_assert_has_args_le "$#" 1
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]] && return 0
    dict['disk']="${1:-/}"
    dict['blocks']="$(koopa_disk_512k_blocks "${dict['disk']}")"
    [[ "${dict['blocks']}" -ge 500000000 ]] && return 0
    return 1
}
