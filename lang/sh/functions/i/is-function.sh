#!/bin/sh

_koopa_is_function() {
    # """
    # Is the specified argument a function?
    # @note Updated 2023-03-27.
    #
    # @example
    # TRUE:
    # > _koopa_is_function '_koopa_koopa_prefix'
    #
    # FALSE:
    # _koopa_is_function 'bash'
    # _koopa_is_function 'tmux-vanilla'
    # """
    for __kvar_cmd in "$@"
    do
        __kvar_string="$(command -v "$__kvar_cmd")"
        [ "$__kvar_string" = "$__kvar_cmd" ] && continue
        unset -v __kvar_cmd __kvar_string
        return 1
    done
    unset -v __kvar_cmd __kvar_string
    return 0
}
