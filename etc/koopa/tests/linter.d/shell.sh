#!/usr/bin/env bash
# shellcheck disable=SC2119

# shellcheck source=/dev/null
source "$(koopa header bash)"

main() {
    # """
    # Shell script checks.
    # Updated 2025-05-08.
    # """
    test_all
    test_posix
    test_bash
    test_zsh
    test_shellcheck
    return 0
}

test_all() {
    local -a files
    readarray -t files <<< \
        "$(koopa_test_find_files_by_shebang '^#!/.+\b(bash|sh|zsh)$')"
    test_all_quoting "${files[@]}"
    test_all_illegal_strings "${files[@]}"
    return 0
}

test_all_illegal_strings() {
    local array pattern
    koopa_assert_has_args "$#"
    # shellcheck disable=SC2016,SC1112
    array=(
        # "=''"             # now allowed, for arrays.
        ' \|\| exit'        # wrap in function and return instead
        ' path='            # zsh will freak out
        '; do'              # newline instead
        '; then'            # newline instead
        '<  <'              # use '<<<' instead
        'IFS= '             # this is default, look for weird edge cases
        '[=|]""$'
        '[“”‘’]'            # no unicode quotes
        '\$path'            # zsh will freak out
        # > '\(\) \{$'      # functions should include vim marker
        '\b(EOF|EOL)\b'     # Use 'END' instead.
        '^path='            # can mess up Zsh PATH
        '_exe\b'
    )
    pattern="$(koopa_paste --sep='|' "${array[@]}")"
    koopa_test_grep \
        --ignore='illegal-strings' \
        --name='shell | all | illegal-strings' \
        --pattern="$pattern" \
        "$@"
    return 0
}

test_all_quoting() {
    local array pattern
    koopa_assert_has_args "$#"
    array=(
        "'\$.+'"
        ":-['\"]"
        # > "^((?!').)*[ =\(]\"[^'\$\"]+\"+$"
        # > '\\\"\$'
        # > '\}\\\"'
    )
    # Check for escaped double quotes.
    # > array+=(
    # > )
    for pattern in "${array[@]}"
    do
        koopa_test_grep \
            --ignore='quoting' \
            --name="shell | all | quoting | ${pattern}" \
            --pattern="$pattern" \
            "$@"
    done
    return 0
}

test_bash() {
    # """
    # Bash shell checks.
    # @note Updated 2022-10-07.
    # """
    local files
    readarray -t files <<< \
       "$(koopa_test_find_files_by_shebang '^#!/.+\b(bash)$')"
    test_bash_illegal_strings "${files[@]}"
    return 0
}

test_bash_illegal_strings() {
    local array pattern
    koopa_assert_has_args "$#"
    array=(
        ' \[ '
        ' \] '
        ' \]$'
        '\[\[ ([^\]]+) = ([^\]]+) \]\]'
        '^\[ '
    )
    pattern="$(koopa_paste --sep='|' "${array[@]}")"
    koopa_test_grep \
        --ignore='illegal-strings' \
        --name='shell | bash | illegal-strings' \
        --pattern="$pattern" \
        "$@"
    return 0
}

test_posix() {
    # """
    # POSIX shell checks.
    # @note Updated 2020-07-08.
    # """
    local files
    readarray -t files <<< \
        "$(koopa_test_find_files_by_shebang '^#!/bin/sh$')"
    test_posix_illegal_strings "${files[@]}"
    return 0
}

test_posix_illegal_strings() {
    local array pattern
    koopa_assert_has_args "$#"
    array=(
        ' == '
        ' \[\[ '
        ' \]\] '
        ' \]\]$'
        '\[@\]\}'
        '\bexit\b'
        '^\[\[ '
    )
    pattern="$(koopa_paste --sep='|' "${array[@]}")"
    koopa_test_grep \
        --ignore='illegal-strings' \
        --name='shell | posix | illegal-strings' \
        --pattern="$pattern" \
        "$@"
    return 0
}

test_zsh() {
    # """
    # Zsh shell checks.
    # @note Updated 2022-10-07.
    # """
    local files
    readarray -t files <<< \
        "$(koopa_test_find_files_by_shebang '^#!/.+\b(zsh)$')"
    test_zsh_illegal_strings "${files[@]}"
    return 0
}

test_zsh_illegal_strings() {
    local array pattern
    koopa_assert_has_args "$#"
    array=(
        ' \[ '
        ' \] '
        ' \]$'
        '\[\[ ([^\]]+) = ([^\]]+) \]\]'
        '^\[ '
    )
    pattern="$(koopa_paste --sep='|' "${array[@]}")"
    koopa_test_grep \
        --ignore='illegal-strings' \
        --name='shell | zsh | illegal-strings' \
        --pattern="$pattern" \
        "$@"
    return 0
}

test_shellcheck() {
    # """
    # Run ShellCheck.
    # @note Updated 2023-03-09.
    #
    # Only Bash and POSIX (but not Zsh) are supported.
    # """
    local app
    declare -A app=(
        ['shellcheck']="$(koopa_locate_shellcheck)"
    )
    readarray -t files <<< \
        "$(koopa_test_find_files_by_shebang '^#!/.+\b(bash|sh)$')"
    # Consider running with:
    # > --exclude='SC2119,SC2120,SC3040,SC3043'
    "${app['shellcheck']}" --external-sources "${files[@]}"
    koopa_status_ok "shell | shellcheck [${#files[@]}]"
    return 0
}

main "$@"
