#!/bin/sh

_koopa_is_alias() {
    # """
    # Is the specified argument an alias?
    # @note Updated 2023-03-11.
    #
    # Intended primarily to determine if we need to unalias.
    # Tracked aliases (e.g. 'dash' to '/bin/dash') don't need to be unaliased.
    #
    # @example
    # > _koopa_is_alias 'R'
    # """
    for __kvar_alias in "$@"
    do
        if ! _koopa_is_installed "$__kvar_alias"
        then
            unset -v __kvar_alias
            return 1
        fi
        __kvar_string="$(type "$__kvar_alias")"
        unset -v __kvar_alias
        # Bash convention.
        _koopa_str_detect_posix \
            "$__kvar_string" \
            ' is aliased to ' \
            && continue
        # Zsh convention.
        _koopa_str_detect_posix \
            "$__kvar_string" \
            ' is an alias for ' \
            && continue
        unset -v __kvar_string
        return 1
    done
    unset -v __kvar_string
    return 0
}
