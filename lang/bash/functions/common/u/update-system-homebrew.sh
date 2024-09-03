#!/usr/bin/env bash

# FIXME Need to improve cleanup of deprecated / removed casks:
# brew uninstall --cask font-ibm-plex 2>/dev/null || true
# To do this, parse the cask list output and only run the uninstall command
# if installed.

koopa_update_system_homebrew() {
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2024-05-16.
    #
    # @seealso
    # - brew linkage --test
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    # """
    local -A app dict
    local -a taps
    local tap
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_assert_is_owner
    if koopa_is_macos
    then
        koopa_macos_assert_is_xcode_clt_installed
    fi
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(koopa_homebrew_prefix)"
    dict['user_id']="$(koopa_user_id)"
    koopa_assert_is_dir \
        "${dict['prefix']}" \
        "${dict['prefix']}/bin"
    koopa_alert_update_start 'Homebrew' "${dict['prefix']}"
    koopa_brew_reset_permissions
    koopa_alert 'Updating Homebrew.'
    koopa_add_to_path_start "${dict['prefix']}/bin"
    "${app['brew']}" analytics off
    "${app['brew']}" update
    if koopa_is_macos
    then
        koopa_macos_brew_upgrade_casks
    fi
    koopa_brew_upgrade_brews
    koopa_alert 'Cleaning up.'
    taps=(
        'homebrew/cask'
        'homebrew/cask-drivers'
        'homebrew/cask-fonts'
        'homebrew/cask-versions'
        'homebrew/core'
    )
    for tap in "${taps[@]}"
    do
        local tap_prefix
        tap_prefix="$("${app['brew']}" --repo "$tap")"
        if [[ -d "$tap_prefix" ]]
        then
            koopa_alert "Untapping '${tap}'."
            "${app['brew']}" untap "$tap"
        fi
    done
    "${app['brew']}" cleanup -s || true
    koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove || true
    koopa_brew_doctor
    koopa_alert_update_success 'Homebrew' "${dict['prefix']}"
    return 0
}
