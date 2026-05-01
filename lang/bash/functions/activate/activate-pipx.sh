#!/usr/bin/env bash

_koopa_activate_pipx() {
    [[ -x "$(_koopa_bin_prefix)/pipx" ]] || return 0
    local prefix
    prefix="$(_koopa_pipx_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
        mkdir -p "$prefix" >/dev/null
    fi
    _koopa_add_to_path_start "${prefix}/bin"
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}
