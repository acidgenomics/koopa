#!/bin/sh

_koopa_activate_rbenv() {
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2023-03-10.
    # """
    [ -n "${RBENV_ROOT:-}" ] && return 0
    __kvar_prefix="$(_koopa_rbenv_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_rbenv="${__kvar_prefix}/bin/rbenv"
    if [ ! -r "$__kvar_rbenv" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_rbenv
        return 0
    fi
    export RBENV_ROOT="$__kvar_prefix"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_rbenv" init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_rbenv
    return 0
}
