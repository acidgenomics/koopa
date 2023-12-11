#!/bin/sh

_koopa_activate_homebrew() {
    # """
    # Activate Homebrew.
    # @note Updated 2023-12-11.
    # """
    # Skip this on HMS O2 cluster.
    [ -n "${HMS_CLUSTER:-}" ] && return 0
    __kvar_prefix="$(_koopa_homebrew_prefix)"
    if [ ! -x "${__kvar_prefix}/bin/brew" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ] && \
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ] && \
        export HOMEBREW_INSTALL_CLEANUP=1
    [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ] && \
        export HOMEBREW_NO_ENV_HINTS=1
    unset -v __kvar_prefix
    return 0
}
