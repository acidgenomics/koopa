#!/usr/bin/env bash

koopa:::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2022-02-01.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [branch]='develop'
        [opt_prefix]="$(koopa::opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/syl20bnr/spacemacs.git'
    )
    if [[ ! -d "${dict[opt_prefix]}/chemacs" ]]
    then
        koopa::stop 'Install chemacs first.'
    fi
    koopa::git_clone --branch='develop' "${dict[url]}" "${dict[prefix]}"
    return 0
}
