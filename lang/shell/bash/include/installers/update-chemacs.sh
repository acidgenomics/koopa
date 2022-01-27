#!/usr/bin/env bash

koopa:::update_chemacs() { # {{{1
    # """
    # Update Chemacs2.
    # @note Updated 2021-11-22.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa::git_pull "${dict[prefix]}"
    return 0
}
