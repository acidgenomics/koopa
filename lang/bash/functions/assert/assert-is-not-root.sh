#!/usr/bin/env bash

_koopa_assert_is_not_root() {
    # """
    # Assert that current user is not root.
    # @note Updated 2019-12-17.
    # """
    _koopa_assert_has_no_args "$#"
    if _koopa_is_root
    then
        _koopa_stop 'root user detected.'
    fi
    return 0
}
