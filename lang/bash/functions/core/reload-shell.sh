#!/usr/bin/env bash

_koopa_reload_shell() {
    # """
    # Reload the current shell.
    # @note Updated 2023-03-10.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    app['shell']="$(_koopa_shell_name)"
    _koopa_assert_is_executable "${app[@]}"
    # shellcheck disable=SC2093
    exec "${app['shell']}" -il
    return 0
}
