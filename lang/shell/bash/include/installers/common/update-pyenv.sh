#!/usr/bin/env bash

update_pyenv() { # {{{1
    # """
    # Update pyenv.
    # @note Updated 2021-11-24.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa_git_pull "${dict[prefix]}"
    return 0
}
