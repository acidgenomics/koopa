#!/usr/bin/env bash

koopa:::update_homebrew() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2021-11-22.
    #
    # @seealso
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    # """
    local app dict
    koopa::assert_is_admin
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    declare -A dict=(
        [reset]=0
    )
    while (("$#"))
    do
        case "$1" in
            '--no-reset')
                dict[reset]=0
                shift 1
                ;;
            '--reset')
                dict[reset]=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    if ! koopa::is_xcode_clt_installed
    then
        koopa::stop 'Need to reinstall Xcode CLT.'
    fi
    if [[ "${dict[reset]}" -eq 1 ]]
    then
        koopa::brew_reset_permissions
        koopa::brew_reset_core_repo
    fi
    "${app[brew]}" analytics off
    "${app[brew]}" update &>/dev/null
    if koopa::is_macos
    then
        koopa::macos_brew_upgrade_casks
    fi
    koopa::brew_upgrade_brews
    koopa::brew_cleanup
    if [[ "${dict[reset]}" -eq 1 ]]
    then
        koopa::brew_reset_permissions
    fi
    return 0
}
