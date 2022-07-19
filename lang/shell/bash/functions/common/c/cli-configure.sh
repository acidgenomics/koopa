#!/usr/bin/env bash

# FIXME May need to override to allow the user to configure system R here.
# FIXME Simplify this, passing in a single language per call, which makes
# configuration of a specific R or Python easier. Don't look across multiple
# programmling languages here.

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
