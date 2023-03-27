#!/usr/bin/env bash

koopa_stat_user_id() {
    # """
    # Get the current user (owner) identifier of a file or directory.
    # @note Updated 2023-03-26.
    #
    # @examples
    # > koopa_stat_user_id '/tmp' "${HOME:?}"
    # # 0
    # # 501
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    declare -A app dict
    dict['format_string']='%u'
    if koopa_is_macos
    then
        app['stat']='/usr/bin/stat'
        dict['format_flag']='-f'
    else
        app['stat']="$(koopa_locate_stat --allow-system)"
        dict['format_flag']='--format'
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
