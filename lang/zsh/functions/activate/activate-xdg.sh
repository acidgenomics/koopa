#!/usr/bin/env zsh

_koopa_activate_xdg() {
    [[ -z "${XDG_CACHE_HOME:-}" ]] && XDG_CACHE_HOME="${HOME:?}/.cache"
    [[ -z "${XDG_CONFIG_DIRS:-}" ]] && XDG_CONFIG_DIRS='/etc/xdg'
    [[ -z "${XDG_CONFIG_HOME:-}" ]] && XDG_CONFIG_HOME="${HOME:?}/.config"
    [[ -z "${XDG_DATA_DIRS:-}" ]] && XDG_DATA_DIRS='/usr/local/share:/usr/share'
    [[ -z "${XDG_DATA_HOME:-}" ]] && XDG_DATA_HOME="${HOME:?}/.local/share"
    [[ -z "${XDG_STATE_HOME:-}" ]] && XDG_STATE_HOME="${HOME:?}/.local/state"
    export \
        XDG_CACHE_HOME \
        XDG_CONFIG_DIRS \
        XDG_CONFIG_HOME \
        XDG_DATA_DIRS \
        XDG_DATA_HOME \
        XDG_STATE_HOME
    return 0
}
