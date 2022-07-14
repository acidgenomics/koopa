#!/usr/bin/env bash

main() {
    # """
    # Install dotfiles.
    # @note Updated 2022-07-14.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [commit]="${INSTALL_VERSION:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/acidgenomics/dotfiles.git'
    )
    koopa_git_clone \
        --commit="${dict[commit]}" \
        --prefix="${dict[prefix]}" \
        --url="${dict[url]}"
    koopa_configure_dotfiles "${dict[prefix]}"
    return 0
}
