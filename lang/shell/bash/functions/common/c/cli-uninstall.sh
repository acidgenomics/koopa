#!/usr/bin/env bash

koopa_cli_uninstall() {
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2022-02-15.
    #
    # @seealso
    # > koopa_cli_uninstall 'python'
    # """
    local app
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    stem='uninstall'
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
        declare -A dict=(
            [key]="${stem}-${app}"
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
