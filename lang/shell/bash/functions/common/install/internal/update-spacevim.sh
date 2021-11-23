#!/usr/bin/env bash

koopa:::update_spacevim() { # {{{1
    # """
    # Update SpaceVim.
    # @note Updated 2021-11-23.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    # FIXME This isn't currently working, need to fix.
    koopa::git_pull "${dict[prefix]}"
    return 0
}
