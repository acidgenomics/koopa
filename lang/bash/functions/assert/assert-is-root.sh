#!/usr/bin/env bash

_koopa_assert_is_root() {
    # """
    # Assert that the current user is root.
    # @note Updated 2019-12-17.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_root
    then
        _koopa_stop 'root user is required.'
    fi
    return 0
}
