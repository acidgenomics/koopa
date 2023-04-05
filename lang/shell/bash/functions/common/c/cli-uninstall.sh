#!/usr/bin/env bash

koopa_cli_uninstall() {
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2023-03-14.
    #
    # @seealso
    # > koopa_cli_uninstall 'python3.10'
    # """
    local app
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    stem='uninstall'
    case "$1" in
        'private' | \
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
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
