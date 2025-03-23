#!/usr/bin/env bash

koopa_stat_group_name() {
    # """
    # Get the current group name of a file or directory.
    # @note Updated 2023-03-27.
    #
    # @examples
    # > koopa_stat_group_name '/tmp' "${HOME:?}"
    # # wheel
    # # staff
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%G'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Sg'
    else
        return 1
    fi
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
