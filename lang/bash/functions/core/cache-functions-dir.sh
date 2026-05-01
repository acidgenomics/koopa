#!/usr/bin/env bash

_koopa_cache_functions_dir() {
    # """
    # Cache a koopa function library directory.
    # @note Updated 2026-04-30.
    # """
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['find']="$(_koopa_locate_find --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -A dict
        dict['prefix']="$prefix"
        _koopa_assert_is_dir "${dict['prefix']}"
        dict['target_file']="${dict['prefix']}.sh"
        _koopa_alert "Caching functions at '${dict['prefix']}' \
in '${dict['target_file']}'."
        if _koopa_str_detect_fixed \
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
