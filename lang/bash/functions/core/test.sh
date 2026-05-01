#!/usr/bin/env bash

_koopa_test() {
    # """
    # Run all koopa unit tests.
    # @note Updated 2022-02-17.
    # """
    local prefix
    _koopa_assert_has_no_args "$#"
    prefix="$(_koopa_tests_prefix)"
    (
        _koopa_cd "$prefix"
        ./linter
        ./shunit2
        # > ./roff
    )
    return 0
}
