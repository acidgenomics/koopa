#!/usr/bin/env bash

koopa_cache_functions() {
    local app dict file files
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1


    # FIXME Require the user to set these manually.
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    dict[prefix]="${dict[koopa_prefix]}/lang/shell/posix"
    dict[target_file]="${dict[prefix]}/functions.sh"


    readarray -t files <<< "$( \
        koopa_find \
            --pattern='*.sh' \
            --prefix="${dict[prefix]}/functions" \
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
        > "${dict[target_file]}.tmp"
    koopa_mv \
        "${dict[target_file]}.tmp" \
        "${dict[target_file]}"
    return 0
}
