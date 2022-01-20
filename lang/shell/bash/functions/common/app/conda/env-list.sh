#!/usr/bin/env bash

koopa::conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-01-17.
    # """
    local app str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa::locate_mamba_or_conda)"
    )
    str="$("${app[conda]}" env list --json --quiet)"
    koopa::print "$str"
    return 0
}
