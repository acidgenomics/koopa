#!/usr/bin/env bash

_koopa_r_system_library_prefix() {
    # """
    # R system library prefix.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(_koopa_locate_r)"
    app['rscript']="${app['r']}script"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    _koopa_assert_is_dir "${dict['prefix']}"
    _koopa_print "${dict['prefix']}"
    return 0
}
