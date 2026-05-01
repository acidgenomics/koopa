#!/usr/bin/env zsh

_koopa_macos_activate_homebrew() {
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    if [[ ! -x "${prefix}/bin/brew" ]]
    then
        return 0
    fi
    local brewfile
    brewfile="$(_koopa_xdg_config_home)/homebrew/Brewfile"
    _koopa_add_to_path_start "${prefix}/bin"
    if [[ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ]] && [[ -f "$brewfile" ]]
    then
        export HOMEBREW_BUNDLE_FILE_GLOBAL="$brewfile"
    fi
    if [[ -z "${HOMEBREW_CLEANUP_MAX_AGE_DAYS:-}" ]]
    then
        export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30
    fi
    if [[ -z "${HOMEBREW_INSTALL_CLEANUP:-}" ]]
    then
        export HOMEBREW_INSTALL_CLEANUP=1
    fi
    if [[ -z "${HOMEBREW_NO_ENV_HINTS:-}" ]]
    then
        export HOMEBREW_NO_ENV_HINTS=1
    fi
    return 0
}
