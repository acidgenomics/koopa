#!/usr/bin/env bash

koopa_stat() {
    # """
    # Display file or file system status.
    # @note Updated 2023-03-18.
    #
    # @examples
    # > koopa_stat '%A' '/tmp/'
    # # drwxrwxrwt
    # """
    local app dict
    koopa_assert_has_args_ge "$#" 2
    declare -A app
    app['stat']="$(koopa_locate_stat --allow-system)"
    [[ -x "${app['stat']}" ]] || return 1
    declare -A dict
    dict['format']="${1:?}"
    shift 1
    if [[ "${app['stat']}" == '/usr/bin/stat' ]] && koopa_is_macos
    then
        ## BSD stat.
        dict['format_flag']='-f'
    else
        ## GNU stat.
        dict['format_flag']='--format'
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" "${dict['format']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}
