#!/usr/bin/env bash
# shellcheck disable=SC2119

# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")/../../lang/shell/bash/include/header.sh"

test() { # {{{1
    # """
    # Shell script checks.
    # Updated 2020-07-20.
    # """
    test_shellcheck
    test_all
    test_posix
    test_bash
    test_zsh
    return 0
}

test_all() { # {{{1
    local files
    koopa::assert_has_no_args "$#"
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.+\b(bash|sh|zsh)$')"
    test_all_quoting "${files[@]}"
    test_all_illegal_strings "${files[@]}"
    test_all_coreutils "${files[@]}"
    return 0
}

# FIXME Need to adjust pattern and exclude comments.
test_all_coreutils() { # {{{1
    local array pattern
    koopa::assert_has_args "$#"
    array=(
        'awk'
        'basename'
        'bc'
        'cd'
        'chgrp'
        'chmod'
        'chown'
        'cp'
        'curl'
        'cut'
        'date'
        'dirname'
        'du'
        'find'
        'grep'
        'id'
        'ln'
        'ls'
        'make'
        'mkdir'
        'mktemp'
        'mv'
        'parallel'
        'patch'
        'readlink'
        'realpath'
        'rm'
        'rsync'
        'sed'
        'sort'
        'stat'
        'tee'
        'tr'
        'uname'
        'wget'
        'which'
        'xargs'
    )
    pattern="$(koopa::paste0 '|' "${array[@]}")"
    pattern="\b${pattern}\b"
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
        '\(\) \{$'          # functions should include vim marker
        '\b(EOF|EOL)\b'     # Use 'END' instead.
        '^path='            # can mess up Zsh PATH
        '_exe\b'
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
    array=(
        "'\$.+'"
        ":-['\"]"
        "^((?!').)*[ =\(]\"[^'\$\"]+\"+$"
        # '\\\"\$'
        # '\}\\\"'
    )
    # Check for escaped double quotes.
    # > array+=(
    # > )
    for pattern in "${array[@]}"
    do
        koopa::test_grep \
            -i 'quoting' \
            -n "shell | all | quoting | ${pattern}" \
            -p "$pattern" \
            "$@"
    done
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
        ' \[ '
        ' \] '
        ' \]$'
        '\[\[ ([^\]]+) = ([^\]]+) \]\]'
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
        ' \[ '
        ' \] '
        ' \]$'
        '\[\[ ([^\]]+) = ([^\]]+) \]\]'
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
    # @note Updated 2021-04-22.
    # Only Bash and POSIX (but not Zsh) are supported.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed shellcheck
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.+\b(bash|sh)$')"
    shellcheck \
        --exclude='SC2119,SC2120,SC3043' \
        --external-sources \
        "${files[@]}"
    koopa::status_ok "shell | shellcheck [${#files[@]}]"
    return 0
}

test "$@"
