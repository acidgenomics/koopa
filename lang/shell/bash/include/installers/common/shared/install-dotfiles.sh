#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install dotfiles.
    # @note Updated 2022-01-18.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/acidgenomics/dotfiles.git'
    )
    koopa_git_clone "${dict[url]}" "${dict[prefix]}"
    koopa_configure_dotfiles "${dict[prefix]}"
    return 0
}
