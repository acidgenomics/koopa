#!/usr/bin/env bash

koopa_disk_pct_used() {
    # """
    # Disk usage percentage (on main drive).
    # @note Updated 2022-08-30.
    # """
    local app disk str
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    declare -A app=(
        ['df']="$(koopa_locate_df --allow-missing)"
        ['head']="$(koopa_locate_head --allow-missing)"
        ['sed']="$(koopa_locate_sed --allow-missing)"
    )
    if [[ ! -x "${app['df']}" ]]
    then
        if [[ -x '/usr/bin/df' ]]
        then
            app['df']='/usr/bin/df'
        elif [[ -x '/bin/df' ]]
        then
            app['df']='/bin/df'
        fi
    fi
    [[ ! -x "${app['head']}" ]] && app['head']='/usr/bin/head'
    [[ ! -x "${app['sed']}" ]] && app['head']='/usr/bin/sed'
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    str="$( \
        "${app['df']}" "$disk" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | koopa_grep \
                --only-matching \
                --pattern='([.0-9]+%)' \
                --regex \
            | "${app['head']}" -n 1 \
            | "${app['sed']}" 's/%$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
