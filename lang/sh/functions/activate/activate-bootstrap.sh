#!/bin/sh

_koopa_activate_bootstrap() {
    # """
    # Conditionally activate koopa bootstrap in current path.
    # @note Updated 2026-05-03.
    #
    # Bootstrap provides Python 3.13 (plus openssl, zlib as build deps).
    # Once koopa has installed python3.14 as an app, the bootstrap is no
    # longer needed.
    # """
    __kvar_bootstrap_prefix="$(_koopa_bootstrap_prefix)"
    if [ ! -d "$__kvar_bootstrap_prefix" ]
    then
        unset -v __kvar_bootstrap_prefix
        return 0
    fi
    __kvar_opt_prefix="$(_koopa_opt_prefix)"
    if [ -d "${__kvar_opt_prefix}/python3.14" ]
    then
        unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
        return 0
    fi
    _koopa_add_to_path_start "${__kvar_bootstrap_prefix}/bin"
    unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
    return 0
}
