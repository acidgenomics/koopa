#!/usr/bin/env zsh

_koopa_activate_rbenv() {
    [[ -n "${RBENV_ROOT:-}" ]] && return 0
    local prefix
    prefix="$(_koopa_rbenv_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local rbenv
    rbenv="${prefix}/bin/rbenv"
    if [[ ! -r "$rbenv" ]]
    then
        return 0
    fi
    export RBENV_ROOT="$prefix"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$rbenv" init -)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
