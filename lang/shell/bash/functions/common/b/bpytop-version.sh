#!/usr/bin/env bash

koopa_bpytop_version() {
    # """
    # bpytop version.
    # @note Updated 2022-07-15.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['bpytop']="${1:-}"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -z "${app['bpytop']}" ]] && app['bpytop']="$(koopa_locate_bpytop)"
    [[ -x "${app['bpytop']}" ]] || return 1
    # shellcheck disable=SC2016
    str="$( \
        "${app['bpytop']}" --version \
            | koopa_grep --pattern='bpytop version:' \
            | "${app['awk']}" '{ print $NF }' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
