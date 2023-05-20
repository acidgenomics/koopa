#!/usr/bin/env bash

koopa_update_system_homebrew() {
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2023-05-20.
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
    # Untap legacy 'homebrew/cask' and 'homebrew/core' if necessary.
    dict['cask_repo']="$("${app['brew']}" --repo 'homebrew/cask')"
    dict['core_repo']="$("${app['brew']}" --repo 'homebrew/core')"
    if [[ -d "${dict['cask_repo']}" ]]
    then
        "${app['brew']}" untap "${dict['cask_repo']}"
    fi
    if [[ -d "${dict['core_repo']}" ]]
    then
        "${app['brew']}" untap "${dict['core_repo']}"
    fi
    "${app['brew']}" analytics off
    "${app['brew']}" update
    if koopa_is_macos
    then
        koopa_macos_brew_upgrade_casks
    fi
    koopa_brew_upgrade_brews
    koopa_alert 'Cleaning up.'
    "${app['brew']}" cleanup -s || true
    koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove || true
    "${app['brew']}" config
    "${app['brew']}" doctor || true
    koopa_alert_update_success 'Homebrew' "${dict['prefix']}"
    return 0
}
