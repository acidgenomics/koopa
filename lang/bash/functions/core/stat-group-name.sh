#!/usr/bin/env bash

_koopa_stat_group_name() {
    # """
    # Get the current group name of a file or directory.
    # @note Updated 2023-03-27.
    #
    # @examples
    # > _koopa_stat_group_name '/tmp' "${HOME:?}"
    # # wheel
    # # staff
    # """
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_existing "$@"
    app['stat']="$(_koopa_locate_stat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%G'
    elif _koopa_is_macos
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
    _koopa_print "${dict['out']}"
    return 0
}
