#!/usr/bin/env bash

koopa_stat_access_human() {
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2023-03-27.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/get-octal-file-permissions-from-
    #     command-line-on-linuxunix/
    #
    # @examples
    # > koopa_stat_access_human '/tmp' "${HOME:?}"
    # # lrwxr-xr-x
    # # drwxr-x---
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    local -A app dict
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%A'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Sp'
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
