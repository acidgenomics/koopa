#!/usr/bin/env bash

koopa:::install_r_cmd_check() { # {{{1
    # """
    # Install r-cmd-check scripts for CI.
    # @note Updated 2021-06-07.
    # """
    local prefix source_repo
    prefix="${INSTALL_PREFIX:?}"
    source_repo='https://github.com/acidgenomics/r-cmd-check.git'
    koopa::git_clone "$source_repo" "$prefix"
    return 0
}

koopa:::update_r_cmd_check() { # {{{1
    # """
    # Update r-cmd-check scripts.
    # @note Updated 2021-09-17.
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="${UPDATE_PREFIX:?}"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    return 0
}
