#!/usr/bin/env bash

# FIXME Need to locate vim.

koopa_detab() {
    # """
    # Detab files.
    # @note Updated 2020-07-13.
    # """
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'vim'
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        vim \
            -c 'set expandtab tabstop=4 shiftwidth=4' \
            -c ':%retab' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}
