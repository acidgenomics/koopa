#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2022-02-01.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [branch]='develop'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/syl20bnr/spacemacs.git'
    )
    if [[ ! -d "${dict[opt_prefix]}/chemacs" ]]
    then
        koopa_stop 'Install chemacs first.'
    fi
    koopa_git_clone --branch='develop' "${dict[url]}" "${dict[prefix]}"
    return 0
}
