#!/bin/sh

_koopa_is_alias() {
    # """
    # Is the specified argument an alias?
    # @note Updated 2023-03-27.
    #
    # @example
    # TRUE:
    # _koopa_is_alias 'tmux-vanilla'
    #
    # FALSE:
    # _koopa_is_alias 'bash'
    # _koopa_is_alias '_koopa_koopa_prefix'
    # """
    for __kvar_cmd in "$@"
    do
        __kvar_string="$(command -v "$__kvar_cmd")"
        case "$__kvar_string" in
            'alias '*)
                continue
                ;;
            *)
                unset -v __kvar_cmd __kvar_string
                return 1
                ;;
        esac
    done
    unset -v __kvar_cmd __kvar_string
    return 0
}
