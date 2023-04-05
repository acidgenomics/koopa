#!/usr/bin/env bash

koopa_file_count() {
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
    local app dict
    koopa_assert_has_args_eq "$#" 1
    local -A app dict
    app['wc']="$(koopa_locate_wc --allow-system)"
    [[ -x "${app['wc']}" ]] || exit 1
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    dict['out']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict['prefix']}" \
        | "${app['wc']}" -l \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}
