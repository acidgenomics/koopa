#!/usr/bin/env bash

koopa_r_version() {
    # """
    # R version.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    koopa_assert_has_args_le "$#" 1
    app['head']="$(koopa_locate_head --allow-system)"
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        R_HOME='' \
        "${app['r']}" --version 2>/dev/null \
            | "${app['head']}" -n 1 \
    )"
    if koopa_str_detect_fixed \
        --string="$str" \
        --pattern='R Under development (unstable)'
    then
        str='devel'
    else
        str="$(koopa_extract_version "$str")"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
