#!/bin/sh

_koopa_activate_pyenv() {
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2025-05-05.
    #
    # Supporting multi-user config here.
    #
    # @seealso
    # - https://github.com/macdub/pyenv-multiuser
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
    export PYENV_LOCAL_SHIM="${HOME:?}/.pyenv_local_shim"
    if [ ! -d "$PYENV_LOCAL_SHIM" ]
    then
        mkdir -p "$PYENV_LOCAL_SHIM"
    fi
    _koopa_add_to_path_start "$PYENV_LOCAL_SHIM"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # > eval "$("$__kvar_pyenv" init -)"
    eval "$("$__kvar_pyenv" virtualenv-init -)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_prefix \
        __kvar_pyenv
    return 0
}
