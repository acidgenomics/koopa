#!/usr/bin/env bash

koopa_test() {
    # """
    # Run all koopa unit tests.
    # @note Updated 2022-02-17.
    # """
    local prefix
    koopa_assert_has_no_args "$#"
    prefix="$(koopa_tests_prefix)"
    (
        koopa_cd "$prefix"
        ./linter
        ./shunit2
        ./check-bin-man-consistency
        # > ./roff
    )
    return 0
}
