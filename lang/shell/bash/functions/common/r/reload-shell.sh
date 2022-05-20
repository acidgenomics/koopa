#!/usr/bin/env bash

koopa_reload_shell() {
    # """
    # Reload the current shell.
    # @note Updated 2022-02-03.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [shell]="$(koopa_locate_shell)"
    )
    # shellcheck disable=SC2093
    exec "${app[shell]}" -il
    return 0
}
