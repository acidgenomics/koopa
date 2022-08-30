#!/usr/bin/env bash

koopa_cache_functions_dir() {
    # """
    # Cache a koopa function library directory.
    # @note Updated 2022-08-29.
    #
    # @section Alternate tr approach for duplicate newlines removal:
    # > "${app['tr']}" -s '\n' '\n' \
    # >     < "${dict['target_file']}" \
    # >     > "${dict['tmp_target_file']}"
    # """
    local app prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        ['grep']="$(koopa_locate_grep --allow-missing)"
        ['perl']="$(koopa_locate_perl --allow-missing)"
    )
    [[ ! -x "${app['grep']}" ]] && app['grep']='/usr/bin/grep'
    [[ -x "${app['grep']}" ]] || return 1
    [[ ! -x "${app['perl']}" ]] && app['perl']='/usr/bin/perl'
    [[ -x "${app['perl']}" ]] || return 1
    for prefix in "$@"
    do
        local dict file files
        declare -A dict=(
            ['prefix']="$prefix"
        )
        koopa_assert_is_dir "${dict['prefix']}"
        dict['target_file']="${dict['prefix']}.sh"
        koopa_alert "Caching functions at '${dict['prefix']}' \
in '${dict['target_file']}'."
        # FIXME This isn't detecting any files.
        readarray -t files <<< "$( \
            koopa_find \
                --pattern='*.sh' \
                --prefix="${dict['prefix']}" \
                --sort \
        )"
        koopa_assert_is_array_non_empty "${files[@]:-}"
        koopa_write_string \
            --file="${dict['target_file']}" \
            --string='#!/bin/sh\n# shellcheck disable=all'
        for file in "${files[@]}"
        do
            # FIXME Can we use koopa_grep here instead?
            "${app['grep']}" -Eiv '^(\s+)?#' "$file" \
            >> "${dict['target_file']}"
        done
        dict['tmp_target_file']="${dict['target_file']}.tmp"
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
