#!/usr/bin/env bash

koopa_check_mount() {
    # """
    # Check if a drive is mounted.
    # @note Updated 2023-03-26.
    #
    # @examples
    # > koopa_check_mount '/mnt/scratch'
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['wc']="$(koopa_locate_wc --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
    if [[ ! -r "${dict['prefix']}" ]] || [[ ! -d "${dict['prefix']}" ]]
    then
        koopa_warn "'${dict['prefix']}' is not a readable directory."
        return 1
    fi
    dict['nfiles']="$( \
        koopa_find \
            --prefix="${dict['prefix']}" \
            --min-depth=1 \
            --max-depth=1 \
        | "${app['wc']}" -l \
    )"
    if [[ "${dict['nfiles']}" -eq 0 ]]
    then
        koopa_warn "'${dict['prefix']}' is unmounted and/or empty."
        return 1
    fi
    return 0
}
