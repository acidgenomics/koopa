#!/usr/bin/env bash

koopa_conda_env_prefix() {
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2022-07-28.
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
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [conda]="$(koopa_locate_conda)"
        [jq]="$(koopa_locate_jq)"
        [sed]="$(koopa_locate_sed)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    declare -A dict=(
        [env_name]="${1:-}"
    )
    dict['env_prefix']="$( \
        "${app['conda']}" info --json | \
            "${app['jq']}" --raw-output '.envs_dirs[0]' \
    )"
    [[ -n "${dict['env_prefix']}" ]] || return 1
    if [[ -z "${dict['env_name']}" ]]
    then
        koopa_print "${dict['env_prefix']}"
        return 0
    fi
    dict['prefix']="${dict['env_prefix']}/${dict['env_name']}"
    if [[ -d "${dict['prefix']}" ]]
    then
        koopa_print "${dict['prefix']}"
        return 0
    fi
    dict['env_list']="$(koopa_conda_env_list)"
    dict['env_list2']="$( \
        koopa_grep \
            --pattern="${dict['env_name']}" \
            --string="${dict['env_list']}" \
    )"
    [[ -n "${dict['env_list2']}" ]] || return 1
    # Note that this step attempts to automatically match the latest version.
    dict['prefix']="$( \
        koopa_grep \
            --pattern="/${dict['env_name']}(@[.0-9]+)?\"" \
            --regex \
            --string="${dict['env_list']}" \
        | "${app['tail']}" -n 1 \
        | "${app['sed']}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    [[ -d "${dict['prefix']}" ]] || return 1
    koopa_print "${dict['prefix']}"
    return 0
}
