#!/usr/bin/env bash

koopa_conda_env_prefix() {
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2022-03-16.
    #
    # Attempt to locate by default path first, which is the fastest approach.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa_conda_env_prefix 'deeptools'
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # - conda info --envs
    # - conda info --json
    # """
    local app dict
    koopa_assert_has_args_le "$#" 2
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
        [env_list]="${2:-}"
    )
    [[ -n "${dict[env_name]}" ]] || return 1
    if [[ -z "${dict[env_list]}" ]]
    then
        dict[conda_prefix]="$(koopa_conda_prefix)"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            koopa_print "${dict[env_prefix]}"
            return 0
        fi
        dict[env_list]="$(koopa_conda_env_list)"
    fi
    dict[env_list2]="$( \
        koopa_grep \
            --pattern="${dict[env_name]}" \
            --string="${dict[env_list]}" \
    )"
    [[ -n "${dict[env_list2]}" ]] || return 1
    # Note that this step attempts to automatically match the latest version.
    dict[env_prefix]="$( \
        koopa_grep \
            --pattern="/${dict[env_name]}(@[.0-9]+)?\"" \
            --regex \
            --string="${dict[env_list]}" \
        | "${app[tail]}" -n 1 \
        | "${app[sed]}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    [[ -d "${dict[env_prefix]}" ]] || return 1
    koopa_print "${dict[env_prefix]}"
    return 0
}
