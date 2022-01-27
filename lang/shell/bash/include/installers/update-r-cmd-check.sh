#!/usr/bin/env bash

koopa:::update_r_cmd_check() { # {{{1
    # """
    # Update r-cmd-check scripts.
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
