#!/usr/bin/env bash

main() {
    # """
    # Update Chemacs2.
    # @note Updated 2021-11-22.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa_git_pull "${dict[prefix]}"
    return 0
}
