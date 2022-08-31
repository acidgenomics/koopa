#!/usr/bin/env bash

koopa_stat() {
    # """
    # Display file or file system status.
    # @note Updated 2022-08-30.
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
    declare -A dict=(
        ['format']="${1:?}"
    )
    shift 1
    dict['out']="$("${app['stat']}" --format="${dict['format']}" "$@")"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}
