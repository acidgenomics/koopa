#!/usr/bin/env bash

koopa::conda_env_prefix() { # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2022-01-17.
    #
    # Attempt to locate by default path first, which is the fastest approach.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa::conda_env_prefix 'deeptools'
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # - conda info --envs
    # - conda info --json
    # """
    local app dict
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
        [env_list]="${2:-}"
    )
    [[ -n "${dict[env_name]}" ]] || return 1
    if [[ -z "${dict[env_list]}" ]]
    then
        dict[conda_prefix]="$(koopa::conda_prefix)"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            koopa::print "${dict[env_prefix]}"
            return 0
        fi
        dict[env_list]="$(koopa::conda_env_list)"
    fi
    dict[env_list2]="$( \
        koopa::print "${dict[env_list]}" \
            | koopa::grep "${dict[env_name]}" \
    )"
    if [[ -z "${dict[env_list2]}" ]]
    then
        koopa::stop "conda environment does not exist: '${dict[env_name]}'."
    fi
    # Note that this step attempts to automatically match the latest version.
    dict[env_prefix]="$( \
        koopa::print "${dict[env_list]}" \
            | koopa::grep --extended-regexp "/${dict[env_name]}(@[.0-9]+)?\"" \
            | "${app[tail]}" -n 1 \
            | "${app[sed]}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa::stop "Failed to resolve conda environment: '${dict[env_name]}'."
    fi
    koopa::print "${dict[env_prefix]}"
    return 0
}
