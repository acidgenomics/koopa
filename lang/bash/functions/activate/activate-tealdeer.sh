#!/usr/bin/env bash

_koopa_activate_tealdeer() {
    [[ -x "$(_koopa_bin_prefix)/tldr" ]] || return 0
    if [[ -z "${TEALDEER_CONFIG_DIR:-}" ]]
    then
        TEALDEER_CONFIG_DIR="$(_koopa_xdg_config_home)/tealdeer"
    fi
    export TEALDEER_CONFIG_DIR
    return 0
}
