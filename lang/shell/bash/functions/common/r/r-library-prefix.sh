#!/usr/bin/env bash

koopa_r_library_prefix() {
    # """
    # R default library prefix.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}
