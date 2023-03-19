#!/bin/sh

_koopa_activate_pipx() {
    # """
    # Activate pipx for Python.
    # @note Updated 2023-03-10.
    #
    # @seealso
    # - https://pypa.github.io/pipx/docs/
    # - https://pipxproject.github.io/pipx/installation/
    # """
    [ -x "$(_koopa_bin_prefix)/pipx" ] || return 0
    __kvar_prefix="$(_koopa_pipx_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        _koopa_is_alias 'mkdir' && unalias 'mkdir'
        mkdir -p "$__kvar_prefix" >/dev/null
    fi
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    PIPX_HOME="$__kvar_prefix"
    PIPX_BIN_DIR="${__kvar_prefix}/bin"
    export PIPX_HOME PIPX_BIN_DIR
    unset -v __kvar_prefix
    return 0
}
