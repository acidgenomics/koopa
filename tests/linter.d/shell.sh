#!/usr/bin/env bash


# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

test() { # {{{1
    # """
    # Shell script checks.
    # Updated 2020-07-20.
    # """
    test_all
    test_posix
    test_bash
    test_zsh
    test_shellcheck
    return 0
}

test_all() { # {{{1
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.+\b(bash|sh|zsh)$')"
    test_all_coreutils "${files[@]}"
    test_all_illegal_strings "${files[@]}"
    test_all_quoting "${files[@]}"
    return 0
}

test_all_coreutils() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    # shellcheck disable=SC2016
    array=('^([ ]+)?(cd|cp|ln|mkdir|mv|rm) ')
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'coreutils' \
        -n 'shell | all | coreutils' \
        -p "$pattern" \
        "$@"
    return 0
}

test_all_illegal_strings() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    # shellcheck disable=SC2016
    array=(
        "=''"
        ' \|\| exit'        # wrap in function and return instead
        ' path='            # zsh will freak out
        '\(\) {$'             # functions should include vim marker
        '; do'              # newline instead
        '; then'            # newline instead
        '<  <'              # use '<<<' instead
        'IFS= '             # this is default, look for weird edge cases
        '[=|]""$'
        '\$path'            # zsh will freak out
        '\b(EOF|EOL)\b'     # Use 'END' instead.
        '^path='            # zsh will freak out
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'illegal-strings' \
        -n 'shell | all | illegal-strings' \
        -p "$pattern" \
        "$@"
    return 0
}

test_all_quoting() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    # shellcheck disable=SC2016
    array=(
        # "'\$"
        ":-'"
        '"[A-Z0-9][-.0-9A-Za-z ]+"'
        ':-"'
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'quoting' \
        -n 'shell | all | quoting' \
        -p "$pattern" \
        "$@"
    return 0
}

test_bash() { # {{{1
    # """
    # Bash shell checks.
    # @note Updated 2020-07-08.
    # """
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< \
       "$(koopa::test_find_files_by_shebang '^#!/.+\b(bash)$')"
    test_bash_illegal_strings "${files[@]}"
    return 0
}

test_bash_illegal_strings() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    array=(
        ' = '
        ' \[ '
        ' \] '
        ' \]$'
        '^\[ '
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'illegal-strings' \
        -n 'shell | bash | illegal-strings' \
        -p "$pattern" \
        "$@"
    return 0
}

test_posix() { # {{{1
    # """
    # POSIX shell checks.
    # @note Updated 2020-07-08.
    # """
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/bin/sh$')"
    test_posix_illegal_strings "${files[@]}"
    return 0
}

test_posix_illegal_strings() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    array=(
        ' == '
        ' \[\[ '
        ' \]\] '
        ' \]\]$'
        '^\[\[ '
        '\[@\]\}'
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'illegal-strings' \
        -n 'shell | posix | illegal-strings' \
        -p "$pattern" \
        "$@"
    return 0
}

test_zsh() { # {{{1
    # """
    # Zsh shell checks.
    # @note Updated 2020-07-08.
    # """
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.+\b(zsh)$')"
    test_zsh_illegal_strings "${files[@]}"
    return 0
}

test_zsh_illegal_strings() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    array=(
        ' = '
        ' \[ '
        ' \] '
        ' \]$'
        '^\[ '
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    koopa::test_grep \
        -i 'illegal-strings' \
        -n 'shell | zsh | illegal-strings' \
        -p "$pattern" \
        "$@"
    return 0
}

test_shellcheck() { # {{{1
    # """
    # Run ShellCheck.
    # @note Updated 2020-07-08.
    # Only Bash and POSIX (but not Zsh) are supported.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed shellcheck
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.+\b(bash|sh)$')"
    shellcheck -x "${files[@]}"
    koopa::status_ok "shell | shellcheck [${#files[@]}]"
    return 0
}

test "$@"
