#!/usr/bin/env bash

koopa_stat_group_name() {
    # """
    # Get the current group name of a file or directory.
    # @note Updated 2023-03-26.
    #
    # @examples
    # > koopa_stat_group_name '/tmp' "${HOME:?}"
    # # wheel
    # # staff
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    declare -A app dict
    if koopa_is_macos
    then
        app['stat']='/usr/bin/stat'
        dict['format_flag']='-f'
        dict['format_string']='%Sg'
    else
        app['stat']="$(koopa_locate_stat --allow-system)"
        dict['format_flag']='--format'
        dict['format_string']='%G'
    fi
    [[ -x "${app['stat']}" ]] || return 1
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}
