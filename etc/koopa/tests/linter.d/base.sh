#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

main() {
    # """
    # Base lint checks.
    # @note Updated 2025-05-08.
    # """
    local files
    koopa_assert_has_no_args "$#"
    readarray -t files <<< "$(koopa_test_find_files)"
    test_illegal_strings "${files[@]}"
    test_line_width "${files[@]}"
    return 0
}

test_illegal_strings() {
    local -a patterns
    koopa_assert_has_args "$#"
    patterns=(
        '<<<<<<<'
        '>>>>>>>'
        '\bFIXME\b'
        '\bTODO\b'
    )
    for pattern in "${patterns[@]}"
    do
        koopa_test_grep \
            --ignore='illegal-strings' \
            --name='base-illegal-strings' \
            --pattern="$pattern" \
            "$@"
    done
    return 0
}

test_line_width() {
    koopa_assert_has_args "$#"
    koopa_test_grep \
        --ignore='line-width' \
        --name='base-line-width' \
        --pattern='^[^\n]{81}' \
        "$@"
    return 0
}

main "$@"
