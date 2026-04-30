#!/usr/bin/env bash

koopa_cache_functions_dir() {
    # """
    # Cache a koopa function library directory.
    # @note Updated 2026-04-30.
    # """
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['find']="$(koopa_locate_find --allow-system)"
    app['grep']="$(koopa_locate_grep --allow-system)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    app['xargs']="$(koopa_locate_xargs --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -A dict
        dict['prefix']="$prefix"
        koopa_assert_is_dir "${dict['prefix']}"
        dict['target_file']="${dict['prefix']}.sh"
        koopa_alert "Caching functions at '${dict['prefix']}' \
in '${dict['target_file']}'."
        if koopa_str_detect_fixed \
            --pattern='/bash/' \
            --string="${dict['prefix']}"
        then
            dict['shebang']='#!/usr/bin/env bash'
        else
            dict['shebang']='#!/bin/sh'
        fi
        {
            printf '%s\n' "${dict['shebang']}"
            printf '%s\n' '# shellcheck disable=all'
            "${app['find']}" "${dict['prefix']}" \
                -type 'f' -name '*.sh' -print0 \
            | "${app['sort']}" -z \
            | "${app['xargs']}" -0 "${app['cat']}" \
            | "${app['grep']}" -Eiv '^(\s+)?#'
        } | "${app['cat']}" -s > "${dict['target_file']}"
    done
    return 0
}
