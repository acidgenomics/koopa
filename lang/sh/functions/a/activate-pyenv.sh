#!/bin/sh

# FIXME Consider setting PYENV_ROOT shims and versions folders outside of
# koopa opt, so we can manage multiple users more efficiently? Can we set
# this to user home instead?

_koopa_activate_pyenv() {
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2023-06-29.
    # """
    [ -n "${PYENV_ROOT:-}" ] && return 0
    __kvar_prefix="$(_koopa_pyenv_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_pyenv="${__kvar_prefix}/bin/pyenv"
    if [ ! -r "$__kvar_pyenv" ]
    then
        unset -v \
            __kvar_prefix \
            __kvar_pyenv
        return 0
    fi
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
    export PYENV_ROOT="$__kvar_prefix"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_pyenv" init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_pyenv
    return 0
}
