#!/usr/bin/env bash

_koopa_macos_brew_upgrade_casks() {
    # """
    # Upgrade Homebrew casks.
    # @note Updated 2025-11-12.
    #
    # Note that additional cask flags are set globally using the
    # 'HOMEBREW_CASK_OPTS' global, declared in our main Homebrew activation
    # function.
    # """
    local -A app
    local -a casks
    local cask
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Checking casks.'
    readarray -t casks <<< "$(_koopa_macos_brew_cask_outdated)"
    if _koopa_is_array_empty "${casks[@]:-}"
    then
        return 0
    fi
    _koopa_dl \
        "$(_koopa_ngettext \
            --num="${#casks[@]}" \
            --msg1='outdated cask' \
            --msg2='outdated casks' \
        )" \
        "$(_koopa_to_string "${casks[@]}")"
    _koopa_sudo_trigger
    # Potentially useful flags:
    # * --display-times
    # * --require-sha
    # * --skip-cask-deps
    # * --verbose
    # * --zap
    "${app['brew']}" reinstall --cask --force "${casks[@]}"
    for cask in "${casks[@]}"
    do
        case "$cask" in
            # > 'google-'*)
            # >     # Currently in 'google-chrome' and 'google-drive' recipes.
            # >     _koopa_macos_disable_google_keystone
            # >     ;;
            'gpg-suite'*)
                _koopa_macos_disable_gpg_updater
                ;;
            # > 'macvim')
            # >     "${app['brew']}" unlink 'vim'
            # >     "${app['brew']}" link 'vim'
            # >     ;;
            # > 'microsoft-teams-classic')
            # >     _koopa_macos_disable_microsoft_teams_updater
            # >     ;;
            'r')
                app['r']="$(_koopa_macos_r_prefix)/bin/R"
                _koopa_configure_r "${app['r']}"
                ;;
        esac
    done
    return 0
}
