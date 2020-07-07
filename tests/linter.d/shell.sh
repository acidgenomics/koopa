#!/usr/bin/env bash

# """
# Run ShellCheck on all Bash and Zsh scripts.
# Updated 2020-06-20.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

test() {
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.*\b(ba)?sh\b$')"
    test_illegal_strings "${files[@]}"
    test_shellcheck "${files[@]}"
    return 0
}

test_illegal_strings() {
    local array pattern
    koopa::assert_has_args "$#"
    # shellcheck disable=SC2016
    array=(
        # "'\$"
        ":-'"
        ' cd '
        ' cp '
        ' ln '
        ' mkdir '
        ' mv '
        ' path='
        ' rm '
        '"[A-Z0-9][-.0-9A-Za-z ]+"'
        ':-"'
        '; do'
        '; then'
        '<  <'
        'IFS=  '
        '\$path'
        '^path='
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'illegal-strings' \
        -n 'shell-illegal-strings' \
        -p "$pattern" \
        "$@"
    return 0
}

test_shellcheck() {
    koopa::assert_has_args "$#"
    koopa::assert_is_installed shellcheck
    shellcheck -x "$@"
    koopa::status_ok "shell-shellcheck [${#files[@]}]"
    return 0
}

test "$@"
