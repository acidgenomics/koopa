#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../lang/shell/bash/include/header.sh"

main() { # {{{1
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
test_illegal_strings() { # {{{1
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

test_line_width() { # {{{1
    koopa_assert_has_args "$#"
    koopa_test_grep \
        --ignore='line-width' \
        --name='base-line-width' \
        --pattern='^[^\n]{81}' \
        "$@"
    return 0
}

main "$@"
