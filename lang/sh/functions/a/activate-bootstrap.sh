#!/bin/sh

_koopa_activate_bootstrap() {
    # """
    # Conditionally activate koopa bootstrap in current path.
    # @note Updated 2024-10-04.
    # """
    __kvar_bootstrap_prefix="$(_koopa_bootstrap_prefix)"
    if [ ! -d "$(_koopa_bootstrap_prefix)" ]
    then
        unset -v __kvar_bootstrap_prefix
        return 0
    fi
    __kvar_opt_prefix="$(_koopa_opt_prefix)"
    [ -d "${__kvar_opt_prefix}/bash" ] || return 0
    [ -d "${__kvar_opt_prefix}/coreutils" ] || return 0
    [ -d "${__kvar_opt_prefix}/openssl3" ] || return 0
    [ -d "${__kvar_opt_prefix}/python3.12" ] || return 0
    [ -d "${__kvar_opt_prefix}/zlib" ] || return 0
    _koopa_add_to_path_start "${__kvar_bootstrap_prefix}/bin"
    unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
    return 0
}
