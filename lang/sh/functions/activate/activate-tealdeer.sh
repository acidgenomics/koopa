#!/bin/sh

_koopa_activate_tealdeer() {
    # """
    # Activate Rust tealdeer (tldr).
    # @note Updated 2025-01-03.
    #
    # This helps standardization the configuration across Linux and macOS.
    #
    # Usage of 'TEALDEER_CACHE_DIR' is now deprecated.
    #
    # @seealso
    # - https://tealdeer-rs.github.io/tealdeer/config.html
    # """
    [ -x "$(_koopa_bin_prefix)/tldr" ] || return 0
    # > if [ -z "${TEALDEER_CACHE_DIR:-}" ]
    # > then
    # >     TEALDEER_CACHE_DIR="$(_koopa_xdg_cache_home)/tealdeer"
    # > fi
    if [ -z "${TEALDEER_CONFIG_DIR:-}" ]
    then
        TEALDEER_CONFIG_DIR="$(_koopa_xdg_config_home)/tealdeer"
    fi
    # > if [ ! -d "${TEALDEER_CACHE_DIR:?}" ]
    # > then
    # >     _koopa_is_alias 'mkdir' && unalias 'mkdir'
    # >     mkdir -p "${TEALDEER_CACHE_DIR:?}" >/dev/null
    # > fi
    # > export TEALDEER_CACHE_DIR
    export TEALDEER_CONFIG_DIR
    return 0
}
