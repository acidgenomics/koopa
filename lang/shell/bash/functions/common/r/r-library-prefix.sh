#!/usr/bin/env bash

koopa_r_library_prefix() {
    # """
    # R default library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    local -A app=(
        ['r']="${1:-}"
    )
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || exit 1
    app['rscript']="${app['r']}script"
    [[ -x "${app['rscript']}" ]] || exit 1
    local -A dict
    dict['prefix']="$( \
        "${app['rscript']}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}
