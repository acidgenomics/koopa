#!/bin/sh

_koopa_activate_ripgrep() {
    # """
    # Activate ripgrep.
    # @note Updated 2023-05-15.
    #
    # @seealso
    # - https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
    # """
    [ -x "${KOOPA_PREFIX:?}/bin/rg" ] || return 0
    __kvar_config_file="${XDG_CONFIG_HOME:?}/ripgrep/config"
    if [ -f "$__kvar_config_file" ]
    then
        RIPGREP_CONFIG_PATH="$__kvar_config_file"
        export RIPGREP_CONFIG_PATH
    fi
    unset -v __kvar_config_file
    return 0
}
