#!/usr/bin/env bash

_koopa_linux_proc_cmdline() {
    # """
    # Get the command line argument for a running process identifier (PID).
    # @note Updated 2023-04-05.
    #
    # @seealso
    # - https://superuser.com/questions/631693/
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['echo']="$(_koopa_locate_echo --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pid']="${1:?}"
    dict['cmdline']="/proc/${dict['pid']}/cmdline"
    _koopa_assert_is_file "${dict['cmdline']}"
    "${app['cat']}" "${dict['cmdline']}" \
        | "${app['xargs']}" -0 "${app['echo']}"
    return 0
}
