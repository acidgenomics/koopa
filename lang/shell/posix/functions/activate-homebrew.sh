#!/bin/sh

koopa_activate_homebrew() {
    # """
    # Activate Homebrew.
    # @note Updated 2022-08-12.
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
        # Alternatively, can add '--no-binaries' here.
        export HOMEBREW_CASK_OPTS='--no-quarantine'
    fi
    return 0
}
