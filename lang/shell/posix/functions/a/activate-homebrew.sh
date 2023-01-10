#!/bin/sh

koopa_activate_homebrew() {
    # """
    # Activate Homebrew.
    # @note Updated 2023-01-10.
    # """
    local prefix
    prefix="$(koopa_homebrew_prefix)"
    [ -d "$prefix" ] || return 0
    [ -x "${prefix}/bin/brew" ] || return 0
    # > export HOMEBREW_PREFIX="$prefix"
    # > [ -z "${HOMEBREW_INSTALL_FROM_API:}" ] && \
    # >     export HOMEBREW_INSTALL_FROM_API=1
    # > [ -z "${HOMEBREW_NO_AUTO_UPDATE:-}" ] && \
    # >     export HOMEBREW_NO_AUTO_UPDATE=1
    [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ] && \
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ] && \
        export HOMEBREW_INSTALL_CLEANUP=1
    [ -z "${HOMEBREW_NO_ANALYTICS:-}" ] && \
        export HOMEBREW_NO_ANALYTICS=1
    [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ] && \
        export HOMEBREW_NO_ENV_HINTS=1
    # > if koopa_is_macos
    # > then
    # >     # Alternatively, can add '--no-binaries' here.
    # >     [ -z "${HOMEBREW_CASK_OPTS:-}" ] && \
    # >         export HOMEBREW_CASK_OPTS='--no-quarantine'
    # > fi
    return 0
}
