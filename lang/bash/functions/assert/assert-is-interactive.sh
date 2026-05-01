#!/usr/bin/env bash

_koopa_assert_is_interactive() {
    # """
    # Assert that current user has admin permissions.
    # @note Updated 2021-05-22.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_interactive
    then
        _koopa_stop 'Shell is not interactive.'
    fi
    return 0
}
