#!/usr/bin/env bash

koopa_conda_pkg_cache_prefix() {
    # """
    # Return conda package cache prefix.
    # @note Updated 2022-07-28.
    #
    # @seealso
    # - conda info --json
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_conda)"
        [jq]="$(koopa_locate_jq)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    declare -A dict
    dict[prefix]="$( \
        "${app['conda']}" info --json \
            | "${app['jq']}" --raw-output '.pkgs_dirs[0]' \
    )"
    [[ -n "${dict['prefix']}" ]] || return 1
    koopa_print "${dict['prefix']}"
    return 0
}
