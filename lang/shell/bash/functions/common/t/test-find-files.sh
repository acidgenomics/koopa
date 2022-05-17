#!/usr/bin/env bash

koopa_test_find_files() {
    # """
    # Find relevant files for unit tests.
    # @note Updated 2022-02-24.
    #
    # Not sorting here can speed the function up.
    # """
    local dict files
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_koopa_prefix)"
    )
    readarray -t files <<< "$( \
        koopa_find \
            --exclude='**/etc/R/**' \
            --exclude='*.1' \
            --exclude='*.md' \
            --exclude='*.ronn' \
            --exclude='*.swp' \
            --exclude='.*' \
            --exclude='.git/**' \
            --exclude='app/**' \
            --exclude='coverage/**' \
            --exclude='etc/R/**' \
            --exclude='opt/**' \
            --exclude='tests/**' \
            --exclude='todo.org' \
            --prefix="${dict[prefix]}" \
            --type='f' \
    )"
    if koopa_is_array_empty "${files[@]:-}"
    then
        koopa_stop 'Failed to find any test files.'
    fi
    koopa_print "${files[@]}"
}
