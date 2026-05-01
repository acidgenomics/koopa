#!/usr/bin/env bash

_koopa_cache_functions_dirs() {
    local -A app dict
    local dir
    _koopa_assert_has_args_ge "$#" 2
    dict['target_file']="${1:?}"
    shift 1
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['find']="$(_koopa_locate_find --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if _koopa_str_detect_fixed \
        --pattern='/bash/' \
        --string="${dict['target_file']}"
    then
        dict['shebang']='#!/usr/bin/env bash'
    else
        dict['shebang']='#!/bin/sh'
    fi
    _koopa_alert "Caching functions in '${dict['target_file']}'."
    {
        printf '%s\n' "${dict['shebang']}"
        printf '%s\n' '# shellcheck disable=all'
        for dir in "$@"
        do
            [[ -d "$dir" ]] || continue
            "${app['find']}" "$dir" \
                -type 'f' -name '*.sh' -print0 \
            | "${app['sort']}" -z \
            | "${app['xargs']}" -0 "${app['cat']}" \
            | "${app['grep']}" -Eiv '^(\s+)?#'
        done
    } | "${app['cat']}" -s > "${dict['target_file']}"
    return 0
}
