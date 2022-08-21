#!/usr/bin/env bash

koopa_cli_update() {
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2022-07-14.
    #
    # @examples
    # > koopa_cli_update 'r-packages'
    # > koopa_cli_update user 'doom-emacs' 'spacemacs'
    # """
    local app stem
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    stem='update'
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
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
    return 0
}
