#!/usr/bin/env bash

koopa:::update_dotfiles() { # {{{1
    # """
    # Update dotfiles repo and run install script, if defined.
    # @note Updated 2022-01-19.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    # > koopa::git_reset "${dict[prefix]}"
    koopa::git_pull "${dict[prefix]}"
    koopa::configure_dotfiles "${dict[prefix]}"
    return 0
}
