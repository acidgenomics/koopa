#!/usr/bin/env bash

_koopa_activate_tealdeer() {
    [[ -x "${KOOPA_PREFIX:?}/bin/tldr" ]] || return 0
    if [[ -z "${TEALDEER_CONFIG_DIR:-}" ]]
    then
        TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME:?}/tealdeer"
    fi
    export TEALDEER_CONFIG_DIR
    return 0
}
