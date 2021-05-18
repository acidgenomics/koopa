#!/bin/sh

__koopa_activate_user_profile() { # {{{1
    # """
    # Activate koopa shell for current user.
    # @note Updated 2021-05-17.
    # @seealso https://koopa.acidgenomics.com/
    # """
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
    if [ -f "${XDG_CONFIG_HOME}/koopa/activate" ]
    then
        # shellcheck source=/dev/null
        . "${XDG_CONFIG_HOME}/koopa/activate"
    fi
    return 0
}

__koopa_activate_user_profile
