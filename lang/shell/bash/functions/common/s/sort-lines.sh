#!/usr/bin/env bash

# FIXME Need to locate vim.

koopa_sort_lines() {
    # """
    # Sort lines.
    # @note Updated 2020-07-13.
    # """
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'vim'
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        vim \
            -c ':sort' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}
