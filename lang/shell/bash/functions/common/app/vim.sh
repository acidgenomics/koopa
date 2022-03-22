#!/usr/bin/env bash

koopa_detab() { # {{{1
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

koopa_entab() { # {{{1
    # """
    # Entab files.
    # @note Updated 2020-07-13.
    # """
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'vim'
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        vim \
            -c 'set noexpandtab tabstop=4 shiftwidth=4' \
            -c ':%retab!' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

koopa_sort_lines() { # {{{1
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
