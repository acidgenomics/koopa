#!/usr/bin/env bash

koopa:::install_dotfiles() { # {{{1
    # """
    # Install dotfiles.
    # @note Updated 2021-11-24.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/acidgenomics/dotfiles.git'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    koopa::configure_dotfiles
    return 0
}
