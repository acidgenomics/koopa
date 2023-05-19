#!/bin/sh

_koopa_activate_tealdeer() {
    # """
    # Activate Rust tealdeer (tldr).
    # @note Updated 2022-10-07.
    #
    # This helps standardization the configuration across Linux and macOS.
    # """
    [ -x "$(_koopa_bin_prefix)/tldr" ] || return 0
    if [ -z "${TEALDEER_CACHE_DIR:-}" ]
    then
        TEALDEER_CACHE_DIR="$(_koopa_xdg_cache_home)/tealdeer"
    fi
    if [ -z "${TEALDEER_CONFIG_DIR:-}" ]
    then
        TEALDEER_CONFIG_DIR="$(_koopa_xdg_config_home)/tealdeer"
    fi
    if [ ! -d "${TEALDEER_CACHE_DIR:?}" ]
    then
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
        mkdir -p "${TEALDEER_CACHE_DIR:?}" >/dev/null
    fi
    export TEALDEER_CACHE_DIR TEALDEER_CONFIG_DIR
    return 0
}
