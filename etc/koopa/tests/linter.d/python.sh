#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

main() {
    # """
    # Python script checks.
    # Updated 2022-10-07.
    # """
    koopa_assert_has_no_args "$#"
    local files
    readarray -t files <<< "$( \
        koopa_find \
            --pattern='*.py' \
            --prefix="$(koopa_koopa_prefix)/lang/python" \
            --sort \
            --type='f' \
    )"
    koopa_is_array_empty "${files[@]}" && return 0
    test_flake8 "${files[@]}"
    test_pylint "${files[@]}"
    return 0
}

test_flake8() {
    local app
    declare -A app
    app['flake8']="$(koopa_locate_flake8)"
    [[ -x "${app['flake8']}" ]] || return 1
    "${app['flake8']}" --ignore='E402,W503' "$@"
    koopa_status_ok "python-flake8 [${#}]"
    return 0
}

test_pylint() {
    local app
    declare -A app
    app['pylint']="$(koopa_locate_pylint)"
    [[ -x "${app['pylint']}" ]] || return 1
    # Note that setting '--jobs=0' flag here enables multicore.
    "${app['pylint']}" --jobs=0 --score='n' "$@"
    koopa_status_ok "python-pylint [${#}]"
    return 0
}

main "$@"
