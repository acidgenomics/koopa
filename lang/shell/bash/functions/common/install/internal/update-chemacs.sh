#!/usr/bin/env bash

koopa:::update_chemacs() { # {{{1
    # """
    # Update Chemacs2.
    # @note Updated 2021-11-20.
    # """
    local dict
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa::git_pull "${dict[prefix]}"
    return 0
}
