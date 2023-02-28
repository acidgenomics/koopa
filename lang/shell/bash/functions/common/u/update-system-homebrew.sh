#!/usr/bin/env bash

koopa_update_system_homebrew() {
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2023-02-28.
    #
    # @seealso
    # - brew linkage --test
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    # """
    local app dict
    koopa_assert_is_admin
    declare -A app dict
    app['brew']="$(koopa_locate_brew)"
    [[ -x "${app['brew']}" ]] || return 1
    dict['reset']=0
    while (("$#"))
    do
        case "$1" in
            '--reset')
                dict['reset']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if koopa_is_macos && \
        ! koopa_macos_is_xcode_clt_installed
    then
        koopa_stop 'Need to reinstall Xcode CLT.'
    fi
    if [[ "${dict['reset']}" -eq 1 ]]
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
    if [[ "${dict['reset']}" -eq 1 ]]
    then
        koopa_brew_reset_permissions
    fi
    return 0
}
