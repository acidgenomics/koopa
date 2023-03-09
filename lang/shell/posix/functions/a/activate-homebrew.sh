#!/bin/sh

_koopa_activate_homebrew() {
    # """
    # Activate Homebrew.
    # @note Updated 2023-02-16.
    # """
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    [ -d "$prefix" ] || return 0
    [ -x "${prefix}/bin/brew" ] || return 0
    [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ] && \
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ] && \
        export HOMEBREW_INSTALL_CLEANUP=1
    [ -z "${HOMEBREW_NO_ANALYTICS:-}" ] && \
        export HOMEBREW_NO_ANALYTICS=1
    [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ] && \
        export HOMEBREW_NO_ENV_HINTS=1
    return 0
}
