#!/bin/sh

koopa_activate_homebrew() {
    # """
    # Activate Homebrew.
    # @note Updated 2022-05-12.
    #
    # Don't activate 'binutils' here. Can mess up R package compilation.
    # """
    local prefix
    prefix="$(koopa_homebrew_prefix)"
    [ -d "$prefix" ] || return 0
    [ -x "${prefix}/bin/brew" ] || return 0
    export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_PREFIX="$prefix"
    if koopa_is_macos
    then
        export HOMEBREW_CASK_OPTS='--no-binaries --no-quarantine'
    fi
    return 0
}
