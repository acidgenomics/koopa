#!/usr/bin/env bash

_koopa_cli_update() {
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2026-05-01.
    #
    # @examples
    # > _koopa_cli_update 'r-packages'
    # > _koopa_cli_update user 'doom-emacs' 'spacemacs'
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
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
        if _koopa_is_function "${dict['fun']}"
        then
            "${dict['fun']}"
        else
            _koopa_cli_install --reinstall "$app"
        fi
    done
    return 0
}
