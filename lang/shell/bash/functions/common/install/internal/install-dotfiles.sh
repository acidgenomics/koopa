#!/usr/bin/env bash

koopa:::install_dotfiles() { # {{{1
    # """
    # Install dotfiles.
    # @note Updated 2021-11-17.
    # """
    local dict
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [repo]='https://github.com/acidgenomics/dotfiles.git'
    )
    koopa::git_clone "${dict[repo]}" "${dict[prefix]}"
    return 0
}
