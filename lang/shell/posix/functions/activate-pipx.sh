#!/bin/sh

koopa_activate_pipx() {
    # """
    # Activate pipx for Python.
    # @note Updated 2022-07-26.
    #
    # @seealso
    # - https://pypa.github.io/pipx/docs/
    # - https://pipxproject.github.io/pipx/installation/
    # """
    local prefix
    [ -x "$(koopa_bin_prefix)/pipx" ] || return 0
    prefix="$(koopa_pipx_prefix)"
    [ ! -d "$prefix" ] && mkdir -p "$prefix"
    koopa_add_to_path_start "${prefix}/bin"
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}
