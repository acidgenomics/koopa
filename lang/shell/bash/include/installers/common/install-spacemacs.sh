#!/usr/bin/env bash

# FIXME Check that chemacs is installed first.

koopa:::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2021-11-23.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [branch]='develop'
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/syl20bnr/spacemacs.git'
    )
    koopa::git_clone --branch='develop' "${dict[url]}" "${dict[prefix]}"
    return 0
}
