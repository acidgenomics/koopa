#!/usr/bin/env bash

_koopa_activate_xdg() {
    if [[ -z "${XDG_CACHE_HOME:-}" ]]
    then
        XDG_CACHE_HOME="$(_koopa_xdg_cache_home)"
    fi
    if [[ -z "${XDG_CONFIG_DIRS:-}" ]]
    then
        XDG_CONFIG_DIRS="$(_koopa_xdg_config_dirs)"
    fi
    if [[ -z "${XDG_CONFIG_HOME:-}" ]]
    then
        XDG_CONFIG_HOME="$(_koopa_xdg_config_home)"
    fi
    if [[ -z "${XDG_DATA_DIRS:-}" ]]
    then
        XDG_DATA_DIRS="$(_koopa_xdg_data_dirs)"
    fi
    if [[ -z "${XDG_DATA_HOME:-}" ]]
    then
        XDG_DATA_HOME="$(_koopa_xdg_data_home)"
    fi
    if [[ -z "${XDG_STATE_HOME:-}" ]]
    then
        XDG_STATE_HOME="$(_koopa_xdg_state_home)"
    fi
    export \
        XDG_CACHE_HOME \
        XDG_CONFIG_DIRS \
        XDG_CONFIG_HOME \
        XDG_DATA_DIRS \
        XDG_DATA_HOME \
        XDG_STATE_HOME
    return 0
}
