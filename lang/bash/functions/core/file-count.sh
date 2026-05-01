#!/usr/bin/env bash

_koopa_file_count() {
    # """
    # Return number of files.
    # @note Updated 2023-03-28.
    #
    # Intentionally doesn't perform this search recursively.
    # Doesn't match the number of directories.
    #
    # Alternate approach:
    # > ls -1 "$prefix" | wc -l
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['wc']="$(_koopa_locate_wc --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    dict['out']="$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict['prefix']}" \
        | "${app['wc']}" -l \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    _koopa_print "${dict['out']}"
    return 0
}
