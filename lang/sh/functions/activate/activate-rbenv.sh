#!/bin/sh

_koopa_activate_rbenv() {
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2023-06-29.
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
    __kvar_nounset=0
    case "$-" in *u*) __kvar_nounset=1 ;; esac
    [ "$__kvar_nounset" -eq 1 ] && set +u
    eval "$("$__kvar_rbenv" init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -u
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_rbenv
    return 0
}
