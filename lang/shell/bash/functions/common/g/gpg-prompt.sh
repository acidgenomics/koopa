#!/usr/bin/env bash

koopa_gpg_prompt() {
    # """
    # Force GPG to prompt for password.
    # @note Updated 2022-05-20.
    #
    # Useful for building Docker images, etc. inside tmux.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpg]="$(koopa_locate_gpg)"
    )
    [[ -x "${app[gpg]}" ]] || return 1
    printf '' | "${app[gpg]}" -s
    return 0
}
