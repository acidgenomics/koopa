#!/usr/bin/env bash

koopa::conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2019-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed conda
    local x
    x="$(conda env list --json)"
    koopa::print "$x"
    return 0
}

koopa::conda_env_prefix() { # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2020-07-05.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa::conda_env_prefix "deeptools"
    # """
    local env_dir env_list env_name x
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed conda
    env_name="${1:?}"
    [[ -n "$env_name" ]] || return 1
    env_list="${2:-$(koopa::conda_env_list)}"
    env_list="$(koopa::print "$env_list" | grep "$env_name")"
    if [[ -z "$env_list" ]]
    then
        koopa::stop "Failed to detect prefix for '${env_name}'."
    fi
    env_dir="$( \
        koopa::print "$env_list" \
        | grep "/envs/${env_name}" \
        | head -n 1 \
    )"
    x="$(koopa::print "$env_dir" | sed -E 's/^.*"(.+)".*$/\1/')"
    koopa::print "$x"
    return 0
}

