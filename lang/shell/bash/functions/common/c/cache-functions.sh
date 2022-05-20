#!/usr/bin/env bash

koopa_cache_functions() {
    # """
    # Cache koopa function library.
    # @note Updated 2022-05-20.
    # """
    local app prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    for prefix in "$@"
    do
        local dict file files
        declare -A dict=(
            [prefix]="$prefix"
        )
        koopa_assert_is_dir "${dict[prefix]}"
        dict[target_file]="${dict[prefix]}.sh"
        koopa_alert "Caching functions at '${dict[prefix]}' \
in '${dict[target_file]}'."
        dict[tmp_target_file]="${dict[target_file]}.tmp"
        readarray -t files <<< "$( \
            koopa_find \
                --pattern='*.sh' \
                --prefix="${dict[prefix]}" \
                --sort \
        )"
        koopa_write_string \
            --file="${dict[target_file]}" \
            --string='#!/bin/sh\n# shellcheck disable=all'
        for file in "${files[@]}"
        do
            "${app[grep]}" \
                --extended-regexp \
                --ignore-case \
                --invert-match \
                '^(\s+)?#' \
                "$file" \
            >> "${dict[target_file]}"
        done
        "${app[tr]}" \
            --squeeze-repeats \
            '\n' \
            '\n' \
            < "${dict[target_file]}" \
            > "${dict[tmp_target_file]}"
        koopa_mv \
            "${dict[tmp_target_file]}" \
            "${dict[target_file]}"
    done
    return 0
}
