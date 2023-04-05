#!/usr/bin/env bash

koopa_cli_configure() {
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2022-12-05.
    #
    # @examples
    # > koopa_cli_configure 'julia' 'r'
    # """
    local app stem
    stem='configure'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        local -A dict=(
            ['key']="${stem}-${app}"
        )
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
    return 0
}
