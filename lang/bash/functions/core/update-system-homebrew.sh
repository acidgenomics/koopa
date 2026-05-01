#!/usr/bin/env bash

_koopa_update_system_homebrew() {
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2025-11-12.
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
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    _koopa_assert_is_owner
    if _koopa_is_macos
    then
        _koopa_macos_assert_is_xcode_clt_installed
    fi
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(_koopa_homebrew_prefix)"
    dict['user_id']="$(_koopa_user_id)"
    _koopa_assert_is_dir \
        "${dict['prefix']}" \
        "${dict['prefix']}/bin"
    _koopa_alert_update_start 'Homebrew' "${dict['prefix']}"
    _koopa_brew_reset_permissions
    _koopa_alert 'Updating Homebrew.'
    _koopa_add_to_path_start "${dict['prefix']}/bin"
    "${app['brew']}" analytics off
    "${app['brew']}" update
    if _koopa_is_macos
    then
        _koopa_macos_brew_upgrade_casks
    fi
    _koopa_brew_upgrade_brews
    _koopa_alert 'Cleaning up.'
    taps=(
        'homebrew/bundle'
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
            _koopa_alert "Untapping '${tap}'."
            "${app['brew']}" untap "$tap"
        fi
    done
    "${app['brew']}" cleanup -s
    _koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove
    _koopa_brew_doctor
    _koopa_alert_update_success 'Homebrew' "${dict['prefix']}"
    return 0
}
