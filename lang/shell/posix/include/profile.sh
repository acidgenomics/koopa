#!/bin/sh

__koopa_activate_user_profile() { # {{{1
    # """
    # Activate koopa shell for current user.
    # @note Updated 2021-06-04.
    # @seealso https://koopa.acidgenomics.com/
    # """
    local script xdg_config_home
    [ "$#" -eq 0 ] || return 1
    xdg_config_home="${XDG_CONFIG_HOME:-}"
    if [ -z "$xdg_config_home" ]
    then
        xdg_config_home="${HOME:?}/.config"
    fi
    script="${xdg_config_home}/koopa/activate"
    if [ -r "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    return 0
}

__koopa_activate_user_profile
