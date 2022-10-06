#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

main() {
    # """
    # Base lint checks.
    # @note Updated 2020-07-08.
    # """
    local files
    koopa_assert_has_no_args "$#"
    readarray -t files <<< "$(koopa_test_find_files)"
    test_illegal_strings "${files[@]}"
    test_line_width "${files[@]}"
    return 0
}

# NOTE This doesn't seem to be picking up FIXMEs.
test_illegal_strings() {
    local array pattern
    koopa_assert_has_args "$#"
    array=(
        '<<<<<<<'
        '>>>>>>>'
        '\bFIXME\b'
        '\bTODO\b'
    )
    pattern="$(koopa_paste --sep='|' "${array[@]}")"
    koopa_test_grep \
        --ignore='illegal-strings' \
        --name='base-illegal-strings' \
        --pattern="$pattern" \
        "$@"
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
