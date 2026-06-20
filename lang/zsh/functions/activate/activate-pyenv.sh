#!/usr/bin/env zsh

_koopa_activate_pyenv() {
    [[ -n "${PYENV_ROOT:-}" ]] && return 0
    local prefix
    prefix="${KOOPA_PREFIX:?}/opt/pyenv"
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
    export PYENV_ROOT="$prefix"
    export PYENV_LOCAL_SHIM="${HOME:?}/.pyenv_local_shim"
    if [[ ! -d "$PYENV_LOCAL_SHIM" ]]
    then
        mkdir -p "$PYENV_LOCAL_SHIM"
    fi
    _koopa_add_to_path_start "$PYENV_LOCAL_SHIM"
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/pyenv-${KOOPA_SHELL##*/}.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$pyenv" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$pyenv" virtualenv-init - > "$cache_file"
    fi
    source "$cache_file"
    unalias pyenv 2>/dev/null || true
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
