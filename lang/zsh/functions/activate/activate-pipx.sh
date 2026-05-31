#!/usr/bin/env zsh

_koopa_activate_pipx() {
    [[ -x "${KOOPA_PREFIX:?}/bin/pipx" ]] || return 0
    local prefix
    prefix="${XDG_DATA_HOME:?}/pipx"
    if [[ ! -d "$prefix" ]]
    then
        mkdir -p "$prefix" >/dev/null
    fi
    _koopa_add_to_path_start "${prefix}/bin"
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}
