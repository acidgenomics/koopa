#!/usr/bin/env bash

koopa_conda_pkg_cache_prefix() {
    # """
    # Return conda package cache prefix.
    # @note Updated 2023-03-20.
    #
    # @seealso
    # - conda info --json
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_no_args "$#"
    app['conda']="$(koopa_locate_conda)"
    app['python']="$(koopa_locate_conda_python)"
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    dict['prefix']="$( \
        "${app['conda']}" info --json \
        | "${app['python']}" -c \
            "import json,sys;print(json.load(sys.stdin)['pkgs_dirs'][0])" \
    )"
    [[ -n "${dict['prefix']}" ]] || return 1
    koopa_print "${dict['prefix']}"
    return 0
}
