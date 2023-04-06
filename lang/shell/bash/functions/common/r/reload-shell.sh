#!/usr/bin/env bash

koopa_reload_shell() {
    # """
    # Reload the current shell.
    # @note Updated 2023-03-10.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['shell']="$(koopa_shell_name)"
    koopa_assert_is_executable "${app[@]}"
    # shellcheck disable=SC2093
    exec "${app['shell']}" -il
    return 0
}
