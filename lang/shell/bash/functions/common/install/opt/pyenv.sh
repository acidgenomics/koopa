#!/usr/bin/env bash

koopa:::install_pyenv() { # {{{1
    # """
    # Install pyenv.
    # @note Updated 2021-11-24.
    # """
    local dict
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/pyenv/pyenv.git'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    return 0
}

koopa:::update_pyenv() { # {{{1
    # """
    # Update pyenv.
    # @note Updated 2021-11-24.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa::git_pull "${dict[prefix]}"
    return 0
}
