#!/bin/sh

_koopa_macos_activate_homebrew() {
    # """
    # Activate Homebrew on macOS.
    # @note Updated 2025-11-12.
    # """
    __kvar_prefix="$(_koopa_homebrew_prefix)"
    if [ ! -x "${__kvar_prefix}/bin/brew" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_brewfile="$(_koopa_xdg_config_home)/homebrew/Brewfile"
    _koopa_add_to_path_start "${__kvar_prefix}/bin"
    if [ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ] && [ -f "$__kvar_brewfile" ]
    then
        export HOMEBREW_BUNDLE_FILE_GLOBAL="$__kvar_brewfile"
    fi
    if [ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ]
    then
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    fi
    if [ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ]
    then
        export HOMEBREW_INSTALL_CLEANUP=1
    fi
    if [ -z "${HOMEBREW_NO_ENV_HINTS:-}" ]
    then
        export HOMEBREW_NO_ENV_HINTS=1
    fi
    unset -v __kvar_brewfile __kvar_prefix
    return 0
}
