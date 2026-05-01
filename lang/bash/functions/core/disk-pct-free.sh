#!/usr/bin/env bash

_koopa_disk_pct_free() {
    # """
    # Free disk space percentage (on main drive).
    # @note Updated 2022-09-01.
    #
    # @examples
    # > _koopa_disk_pct_free '/'
    # # 48
    # """
    local disk pct_free pct_used
    _koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    _koopa_assert_is_readable "$disk"
    pct_used="$(_koopa_disk_pct_used "$disk")"
    pct_free="$((100 - pct_used))"
    _koopa_print "$pct_free"
    return 0
}
