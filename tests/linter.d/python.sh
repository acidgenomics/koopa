#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../lang/shell/bash/include/header.sh"

test() { # {{{1
    # """
    # Python script checks.
    # Updated 2021-02-15.
    # """
    koopa::assert_has_no_args "$#"
    local files
    readarray -t files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.*\bpython(3)?\b$')"
    koopa::is_array_empty "${files[@]}" && return 0
    test_flake8 "${files[@]}"
    test_pylint "${files[@]}"
    return 0
}

test_flake8() { # {{{1
    koopa::assert_is_installed flake8
    flake8 --ignore='E402,W503' "$@"
    koopa::status_ok "python-flake8 [${#}]"
    return 0
}

test_pylint() { # {{{1
    # Note that setting '--jobs=0' flag here enables multicore.
    koopa::assert_is_installed pylint
    pylint --jobs=0 --score='n' "$@"
    koopa::status_ok "python-pylint [${#}]"
    return 0
}

test "$@"
