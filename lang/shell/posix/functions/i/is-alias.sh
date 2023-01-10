#!/bin/sh

koopa_is_alias() {
    # """
    # Is the specified argument an alias?
    # @note Updated 2022-01-10.
    #
    # Intended primarily to determine if we need to unalias.
    # Tracked aliases (e.g. 'dash' to '/bin/dash') don't need to be unaliased.
    #
    # @example
    # > koopa_is_alias 'R'
    # """
    local cmd str
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$(type "$cmd")"
        # Bash convention.
        koopa_str_detect_posix "$str" ' is aliased to ' && continue
        # Zsh convention.
        koopa_str_detect_posix "$str" ' is an alias for ' && continue
        return 1
    done
    return 0
}
