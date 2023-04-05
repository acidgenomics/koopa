#!/usr/bin/env bash

koopa_reload_shell() {
    # """
    # Reload the current shell.
    # @note Updated 2023-03-10.
    # """
    local app
    koopa_assert_has_no_args "$#"
    local -A app
    app['shell']="$(koopa_shell_name)"
    [[ -x "${app['shell']}" ]] || exit 1
    # shellcheck disable=SC2093
    exec "${app['shell']}" -il
    return 0
}
