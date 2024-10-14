#!/bin/sh

# FIXME Need to document that we need to update python3.12 check here on
# a version bump, say to python3.13.

_koopa_activate_bootstrap() {
    # """
    # Conditionally activate koopa bootstrap in current path.
    # @note Updated 2024-10-14.
    # """
    __kvar_bootstrap_prefix="$(_koopa_bootstrap_prefix)"
    if [ ! -d "$(_koopa_bootstrap_prefix)" ]
    then
        unset -v __kvar_bootstrap_prefix
        return 0
    fi
    __kvar_opt_prefix="$(_koopa_opt_prefix)"
    if [ \( -d "${__kvar_opt_prefix}/bash" \) \
        -a \( -d "${__kvar_opt_prefix}/coreutils" \) \
        -a \( -d "${__kvar_opt_prefix}/openssl3" \) \
        -a \( -d "${__kvar_opt_prefix}/python3.12" \) \
        -a \( -d "${__kvar_opt_prefix}/zlib" \) ]
    then
        unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
        return 0
    fi
    _koopa_add_to_path_start "${__kvar_bootstrap_prefix}/bin"
    unset -v __kvar_bootstrap_prefix __kvar_opt_prefix
    return 0
}
