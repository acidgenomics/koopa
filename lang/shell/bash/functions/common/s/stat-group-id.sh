#!/usr/bin/env bash

koopa_stat_group_id() {
    # """
    # Get the current group name of a file or directory.
    # @note Updated 2023-03-27.
    #
    # @examples
    # > koopa_stat_group_id '/tmp' "${HOME:?}"
    # # 0
    # # 20
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    local -A app dict
    app['stat']="$(koopa_locate_stat --allow-system)"
    [[ -x "${app['stat']}" ]] || exit 1
    dict['format_string']='%g'
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
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
