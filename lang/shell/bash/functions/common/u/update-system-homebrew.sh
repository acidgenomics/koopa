#!/usr/bin/env bash

koopa_update_system_homebrew() {
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2023-05-09.
    #
    # @seealso
    # - brew linkage --test
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    # """
    local -A app bool dict
    local -a dirs
    local dir
    koopa_assert_is_admin
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    bool['reset']=0
    dict['prefix']="$(koopa_homebrew_prefix)"
    dict['user_id']="$(koopa_user_id)"
    koopa_assert_is_dir "${dict['prefix']}"
    if [[ "$(koopa_stat_user_id "${dict['prefix']}")" != "${dict['user_id']}" ]]
    then
        koopa_stop 'Homebrew is not managed by current user.'
    fi
    if koopa_is_macos && ! koopa_macos_is_xcode_clt_installed
    then
        koopa_macos_install_system_xcode_clt
        koopa_stop \
            'Xcode Command Line Tools are missing.' \
            "Run 'koopa install system xcode-clt' to resolve."
    fi
    dirs=(
        "${dict['prefix']}/bin"
        "${dict['prefix']}/etc"
        "${dict['prefix']}/etc/bash_completion.d"
        "${dict['prefix']}/include"
        "${dict['prefix']}/lib"
        "${dict['prefix']}/lib/pkgconfig"
        "${dict['prefix']}/sbin"
        "${dict['prefix']}/share"
        "${dict['prefix']}/share/doc"
        "${dict['prefix']}/share/info"
        "${dict['prefix']}/share/locale"
        "${dict['prefix']}/share/man"
        "${dict['prefix']}/share/man/man1"
        "${dict['prefix']}/share/zsh"
        "${dict['prefix']}/share/zsh/site-functions"
        "${dict['prefix']}/var/homebrew/linked"
        "${dict['prefix']}/var/homebrew/locks"
    )
    for dir in "${dirs[@]}"
    do
        [[ "${bool['reset']}" -eq 0 ]] || continue
        [[ -d "$dir" ]] || continue
        [[ "$(koopa_stat_user_id "$dir")" == "${dict['user_id']}" ]] && continue
        bool['reset']=1
    done
    if [[ "${bool['reset']}" -eq 1 ]]
    then
        koopa_brew_reset_permissions
        koopa_brew_reset_core_repo
    fi
    "${app['brew']}" analytics off
    "${app['brew']}" update &>/dev/null
    if koopa_is_macos
    then
        koopa_macos_brew_upgrade_casks
    fi
    koopa_brew_upgrade_brews
    koopa_brew_cleanup
    return 0
}
