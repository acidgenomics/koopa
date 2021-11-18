#!/usr/bin/env bash

# FIXME Can we call git_pull directly on a prefix?
# FIXME This would be cool for eliminating subshell usage.
koopa:::update_chemacs() { # {{{1
    # """
    # Update Chemacs2.
    # @note Updated 2021-11-18.
    # """
    local dict
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    (
        koopa::cd "${dict[prefix]}"
        koopa::git_pull
    )
    return 0
}
