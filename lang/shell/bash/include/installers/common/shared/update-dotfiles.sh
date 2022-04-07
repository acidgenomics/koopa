#!/usr/bin/env bash

main() { # {{{1
    # """
    # Update dotfiles repo and run install script, if defined.
    # @note Updated 2022-01-19.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    dict[script]="${dict[prefix]}/install"
    koopa_assert_is_file "${dict[script]}"
    # > koopa_git_reset "${dict[prefix]}"
    koopa_git_pull "${dict[prefix]}"
    koopa_configure_dotfiles "${dict[prefix]}"
    return 0
}
