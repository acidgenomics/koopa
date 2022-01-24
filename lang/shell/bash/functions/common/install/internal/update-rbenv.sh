#!/usr/bin/env bash

koopa:::update_rbenv() { # {{{1
    # """
    # Update rbenv.
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
