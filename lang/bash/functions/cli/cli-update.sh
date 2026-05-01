#!/usr/bin/env bash

_koopa_cli_update() {
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2022-07-14.
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
        if ! _koopa_is_function "${dict['fun']}"
        then
            _koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
    return 0
}
