#!/usr/bin/env bash

_koopa_activate_rbenv() {
    [[ -n "${RBENV_ROOT:-}" ]] && return 0
    local prefix
    prefix="${KOOPA_PREFIX:?}/opt/rbenv"
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
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/rbenv-${KOOPA_SHELL##*/}.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$rbenv" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$rbenv" init - > "$cache_file"
    fi
    source "$cache_file"
    unalias rbenv 2>/dev/null || true
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
