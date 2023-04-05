#!/usr/bin/env bash

# FIXME Need to confirm that this is working.

koopa_test_find_files_by_shebang() {
    # """
    # Find relevant test files by shebang.
    # @note Updated 2022-10-07.
    #
    # @examples
    # > koopa_test_find_files_by_shebang '^#!/.+\b(bash)$'
    # > koopa_test_find_files_by_shebang '^#!/.+\b(bash|sh)$'
    # > koopa_test_find_files_by_shebang '^#!/.+\b(bash|sh|zsh)$'
    # > koopa_test_find_files_by_shebang '^#!/.+\b(zsh)$'
    # > koopa_test_find_files_by_shebang '^#!/bin/sh$'
    # """
    local all_files app dict file files
    koopa_assert_has_args "$#"
    declare -A app=(
        ['head']="$(koopa_locate_head)"
        ['tr']="$(koopa_locate_tr)"
    )
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['tr']}" ]] || exit 1
    declare -A dict=(
        ['pattern']="${1:?}"
    )
    readarray -t all_files <<< "$(koopa_test_find_files)"
    files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        # Avoid 'command substitution: ignored null byte in input' warning.
        shebang="$( \
            "${app['tr']}" --delete '\0' < "$file" \
                | "${app['head']}" -n 1 \
                || true \
        )"
        [[ -n "$shebang" ]] || continue
        if koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict['pattern']}"
        then
            files+=("$file")
        fi
    done
    if koopa_is_array_empty "${files[@]}"
    then
        koopa_stop "Failed to find files with pattern '${dict['pattern']}'."
    fi
    koopa_print "${files[@]}"
    return 0
}
