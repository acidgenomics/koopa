#!/usr/bin/env bash

koopa_assert_is_not_root() {
    # """
    # Assert that current user is not root.
    # @note Updated 2019-12-17.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_root
    then
        koopa_stop 'root user detected.'
    fi
    return 0
}
