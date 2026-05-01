#!/usr/bin/env bash

_koopa_cache_functions_dirs() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    dict['target_file']="${1:?}"
    dict['source_prefix']="${2:?}"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['find']="$(_koopa_locate_find --allow-system)"
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_dir "${dict['source_prefix']}"
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
        "${app['find']}" "${dict['source_prefix']}" \
            -type 'f' -name '*.sh' -print0 \
        | "${app['sort']}" -z \
        | "${app['xargs']}" -0 "${app['cat']}" \
        | "${app['grep']}" -Eiv '^(\s+)?#'
    } | "${app['cat']}" -s > "${dict['target_file']}"
    return 0
}
