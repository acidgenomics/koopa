#!/usr/bin/env bash

_koopa_activate_pyenv() {
    [[ -n "${PYENV_ROOT:-}" ]] && return 0
    local prefix
    prefix="$(_koopa_pyenv_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local pyenv
    pyenv="${prefix}/bin/pyenv"
    if [[ ! -r "$pyenv" ]]
    then
        return 0
    fi
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
    export PYENV_ROOT="$prefix"
    export PYENV_LOCAL_SHIM="${HOME:?}/.pyenv_local_shim"
    if [[ ! -d "$PYENV_LOCAL_SHIM" ]]
    then
        mkdir -p "$PYENV_LOCAL_SHIM"
    fi
    _koopa_add_to_path_start "$PYENV_LOCAL_SHIM"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$pyenv" virtualenv-init -)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
