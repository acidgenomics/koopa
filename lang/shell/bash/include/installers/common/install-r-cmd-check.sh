#!/usr/bin/env bash

koopa:::install_r_cmd_check() { # {{{1
    # """
    # Install r-cmd-check scripts for CI.
    # @note Updated 2021-11-22.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/acidgenomics/r-cmd-check.git'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    return 0
}

