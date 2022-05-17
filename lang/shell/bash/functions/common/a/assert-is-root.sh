#!/usr/bin/env bash

koopa_assert_is_root() {
    # """
    # Assert that the current user is root.
    # @note Updated 2019-12-17.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_root
    then
        koopa_stop 'root user is required.'
    fi
    return 0
}
