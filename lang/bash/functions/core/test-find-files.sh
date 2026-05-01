#!/usr/bin/env bash

_koopa_test_find_files() {
    # """
    # Find relevant files for unit tests.
    # @note Updated 2023-04-06.
    #
    # Not sorting here can speed the function up.
    # """
    local -A dict
    local -a files
    _koopa_assert_has_no_args "$#"
    dict['prefix']="$(_koopa_koopa_prefix)"
    readarray -t files <<< "$( \
        _koopa_find \
            --exclude='*.swp' \
            --exclude='.*' \
            --exclude='.git/**' \
            --exclude='app/**' \
            --exclude='common.sh' \
            --exclude='coverage/**' \
            --exclude='etc/**' \
            --exclude='libexec/**' \
            --exclude='opt/**' \
            --exclude='share/**' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if _koopa_is_array_empty "${files[@]:-}"
    then
        _koopa_stop 'Failed to find any test files.'
    fi
    _koopa_print "${files[@]}"
}
