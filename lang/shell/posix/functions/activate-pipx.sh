#!/bin/sh

koopa_activate_pipx() {
    # """
    # Activate pipx for Python.
    # @note Updated 2022-03-30.
    #
    # Customize pipx location with environment variables.
    # https://pipxproject.github.io/pipx/installation/
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/pipx" ] || return 0
    prefix="$(koopa_pipx_prefix)"
    [ -d "$prefix" ] || return 0
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}
