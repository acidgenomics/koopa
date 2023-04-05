#!/usr/bin/env bash

koopa_cache_functions_dir() {
    # """
    # Cache a koopa function library directory.
    # @note Updated 2022-10-07.
    #
    # @section Alternate tr approach for duplicate newlines removal:
    # > "${app['tr']}" -s '\n' '\n' \
    # >     < "${dict['target_file']}" \
    # >     > "${dict['tmp_target_file']}"
    # """
    local app prefix
    declare -A app
    koopa_assert_has_args "$#"
    app['grep']="$(koopa_locate_grep --allow-system)"
    app['perl']="$(koopa_locate_perl --allow-system)"
    [[ -x "${app['grep']}" ]] || return 1
    [[ -x "${app['perl']}" ]] || return 1
    for prefix in "$@"
    do
        local dict file files header
        declare -A dict
        dict['prefix']="$prefix"
        koopa_assert_is_dir "${dict['prefix']}"
        dict['target_file']="${dict['prefix']}.sh"
        koopa_alert "Caching functions at '${dict['prefix']}' \
in '${dict['target_file']}'."
        readarray -t files <<< "$( \
            koopa_find \
                --pattern='*.sh' \
                --prefix="${dict['prefix']}" \
                --sort \
        )"
        koopa_assert_is_array_non_empty "${files[@]:-}"
        header=()
        if koopa_str_detect_fixed \
            --pattern='/bash/' \
            --string="${dict['prefix']}"
        then
            header+=('#!/usr/bin/env bash')
        else
            header+=('#!/bin/sh')
        fi
        header+=('# shellcheck disable=all')
        dict['header_string']="$(printf '%s\n' "${header[@]}")"
        koopa_write_string \
            --file="${dict['target_file']}" \
            --string="${dict['header_string']}"
        for file in "${files[@]}"
        do
            # This can be useful for more verbose debugging, but is slower.
            # > koopa_alert "$file"
            # Consider switching to 'koopa_grep' here in a future update.
            "${app['grep']}" -Eiv '^(\s+)?#' "$file" \
            >> "${dict['target_file']}"
        done
        dict['tmp_target_file']="${dict['target_file']}.tmp"
        # Remove extra line breaks.
        "${app['perl']}" \
            -0pe 's/\n\n\n+/\n\n/g' \
            "${dict['target_file']}" \
            > "${dict['tmp_target_file']}"
        koopa_mv \
            "${dict['tmp_target_file']}" \
            "${dict['target_file']}"
    done
    return 0
}
