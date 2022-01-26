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
