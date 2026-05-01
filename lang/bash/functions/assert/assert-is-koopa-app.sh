#!/usr/bin/env bash

_koopa_assert_is_koopa_app() {
    # """
    # Assert that input is an application installed in koopa app prefix.
    # @note Updated 2021-06-14.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_koopa_app "$arg"
        then
            _koopa_stop "Not koopa app: '${arg}'."
        fi
    done
    return 0
}
