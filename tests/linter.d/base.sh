#!/usr/bin/env bash

# shellcheck source=/dev/null
. "$(koopa header bash)"

test() { # {{{1
    # """
    # Base lint checks.
    # @note Updated 2020-07-08.
    # """
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< "$(koopa::test_find_files)"
    test_illegal_strings "${files[@]}"
    test_line_width "${files[@]}"
    return 0
}

test_illegal_strings() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    array=(
        '<<<<<<<'
        '>>>>>>>'
        '\bFIXME\b'
        '\bTODO\b'
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'illegal-strings' \
        -n 'base-illegal-strings' \
        -p "$pattern" \
        "$@"
    return 0
}

test_line_width() { # {{{1
    koopa::assert_has_args "$#"
    koopa::test_grep \
        -i 'line-width' \
        -n 'base-line-width' \
        -p '^[^\n]{81}' \
        "$@"
    return 0
}

test "$@"
