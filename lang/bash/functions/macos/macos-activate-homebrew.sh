#!/usr/bin/env bash

# Equivalent upstream one-liner (not used — would reset PATH before koopa builds it):
# eval "$(/opt/homebrew/bin/brew shellenv)"
_koopa_macos_activate_homebrew() {
    local -A dict
    dict['prefix']="$(_koopa_homebrew_prefix)"
    if [[ ! -x "${dict['prefix']}/bin/brew" ]]
    then
        return 0
    fi
    export HOMEBREW_PREFIX="${dict['prefix']}"
    export HOMEBREW_CELLAR="${dict['prefix']}/Cellar"
    export HOMEBREW_REPOSITORY="${dict['prefix']}"
    dict['brewfile']="${XDG_CONFIG_HOME:?}/homebrew/Brewfile"
    _koopa_add_to_path_start "${dict['prefix']}/bin"
    if [[ -z "${INFOPATH:-}" ]]
    then
        export INFOPATH="${dict['prefix']}/share/info"
    else
        export INFOPATH="${dict['prefix']}/share/info:${INFOPATH}"
    fi
    if [[ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ]] \
        && [[ -f "${dict['brewfile']}" ]]
    then
        export HOMEBREW_BUNDLE_FILE_GLOBAL="${dict['brewfile']}"
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
