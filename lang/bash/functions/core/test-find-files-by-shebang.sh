#!/usr/bin/env bash

# FIXME Need to confirm that this is working.

_koopa_test_find_files_by_shebang() {
    # """
    # Find relevant test files by shebang.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_test_find_files_by_shebang '^#!/.+\b(bash)$'
    # > _koopa_test_find_files_by_shebang '^#!/.+\b(bash|sh)$'
    # > _koopa_test_find_files_by_shebang '^#!/.+\b(bash|sh|zsh)$'
    # > _koopa_test_find_files_by_shebang '^#!/.+\b(zsh)$'
    # > _koopa_test_find_files_by_shebang '^#!/bin/sh$'
    # """
    local -A app dict
    local -a all_files files
    local file
    _koopa_assert_has_args "$#"
    app['head']="$(_koopa_locate_head)"
    app['tr']="$(_koopa_locate_tr)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    readarray -t all_files <<< "$(_koopa_test_find_files)"
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
        if _koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict['pattern']}"
        then
            files+=("$file")
        fi
    done
    if _koopa_is_array_empty "${files[@]}"
    then
        _koopa_stop "Failed to find files with pattern '${dict['pattern']}'."
    fi
    _koopa_print "${files[@]}"
    return 0
}
