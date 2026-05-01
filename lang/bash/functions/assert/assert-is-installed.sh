#!/usr/bin/env bash

_koopa_assert_is_installed() {
    # """
    # Assert that programs are installed.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_stop "Not installed: '${arg}'."
        fi
    done
    return 0
}
