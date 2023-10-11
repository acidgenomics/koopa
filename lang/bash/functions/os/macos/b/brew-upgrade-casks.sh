#!/usr/bin/env bash

koopa_macos_brew_upgrade_casks() {
    # """
    # Upgrade Homebrew casks.
    # @note Updated 2023-10-11.
    #
    # Note that additional cask flags are set globally using the
    # 'HOMEBREW_CASK_OPTS' global, declared in our main Homebrew activation
    # function.
    # """
    local -A app
    local -a casks
    local cask
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Checking casks.'
    readarray -t casks <<< "$(koopa_macos_brew_cask_outdated)"
    koopa_is_array_non_empty "${casks[@]:-}" || return 0
    koopa_dl \
        "$(koopa_ngettext \
            --num="${#casks[@]}" \
            --msg1='outdated cask' \
            --msg2='outdated casks' \
        )" \
        "$(koopa_to_string "${casks[@]}")"
    for cask in "${casks[@]}"
    do
        case "$cask" in
            'docker')
                cask='homebrew/cask/docker'
                ;;
            'macvim')
                cask='homebrew/cask/macvim'
                ;;
        esac
        "${app['brew']}" reinstall --cask --force "$cask" || true
        case "$cask" in
            'r')
                app['r']="$(koopa_macos_r_prefix)/bin/R"
                koopa_configure_r "${app['r']}"
                ;;
            # > 'emacs')
            # >     "${app['brew']}" unlink 'emacs'
            # >     "${app['brew']}" link 'emacs'
            # >     ;;
            'google-'*)
                # Currently in 'google-chrome' and 'google-drive' recipes.
                koopa_macos_disable_google_keystone || true
                ;;
            'gpg-suite'*)
                koopa_macos_disable_gpg_updater
                ;;
            'macvim')
                "${app['brew']}" unlink 'vim'
                "${app['brew']}" link 'vim'
                ;;
            # > 'microsoft-teams-classic')
            # >     koopa_macos_disable_microsoft_teams_updater
            # >     ;;
        esac
    done
    return 0
}
