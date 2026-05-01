#!/usr/bin/env bash

_koopa_disk_pct_used() {
    # """
    # Disk usage percentage (on main drive).
    # @note Updated 2022-09-01.
    #
    # @examples
    # _koopa_disk_pct_used '/'
    # 52
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['df']="$(_koopa_locate_df --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
    _koopa_assert_is_readable "${dict['disk']}"
    # shellcheck disable=SC2016
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $5}' \
            | "${app['sed']}" 's/%$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}
