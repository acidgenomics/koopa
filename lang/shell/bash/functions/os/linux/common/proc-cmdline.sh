#!/usr/bin/env bash

koopa_linux_proc_cmdline() {
    # """
    # Get the command line argument for a running process identifier (PID).
    # @note Updated 2022-07-26.
    #
    # @seealso
    # - https://superuser.com/questions/631693/
    # """
    local app pid
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['cat']="$(koopa_locate_cat)"
        ['echo']="$(koopa_locate_echo)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['echo']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict
    dict['pid']="${1:?}"
    dict['cmdline']="/proc/${dict['pid']}/cmdline"
    koopa_assert_is_file "${dict['cmdline']}"
    "${app['cat']}" "${dict['cmdline']}" \
        | "${app['xargs']}" -0 "${app['echo']}"
    return 0
}

