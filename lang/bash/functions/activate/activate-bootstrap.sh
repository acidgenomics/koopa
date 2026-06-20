#!/usr/bin/env bash

_koopa_activate_bootstrap() {
    local bootstrap_prefix
    bootstrap_prefix="${XDG_DATA_HOME:-${HOME:?}/.local/share}/koopa-bootstrap"
    if [[ ! -d "$bootstrap_prefix" ]]
    then
        return 0
    fi
    local opt_prefix
    opt_prefix="${KOOPA_PREFIX:?}/opt"
    if [[ -d "${opt_prefix}/bash" ]] \
        && [[ -d "${opt_prefix}/coreutils" ]] \
        && [[ -d "${opt_prefix}/openssl3" ]] \
        && [[ -d "${opt_prefix}/python3.12" ]] \
        && [[ -d "${opt_prefix}/zlib" ]]
    then
        return 0
    fi
    _koopa_add_to_path_start "${bootstrap_prefix}/bin"
    return 0
}
