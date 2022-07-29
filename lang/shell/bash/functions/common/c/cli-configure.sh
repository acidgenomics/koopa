#!/usr/bin/env bash

koopa_cli_configure() {
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2022-07-14.
    #
    # @examples
    # > koopa_cli_configure 'julia' 'r'
    # """
    local app
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        declare -A dict=(
            [key]="configure-${app}"
        )
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict[fun]}"
    done
    return 0
}
