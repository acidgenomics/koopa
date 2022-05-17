#!/usr/bin/env bash

koopa_assert_is_array_non_empty() {
    # """
    # Assert that array is non-empty.
    # @note Updated 2020-03-06.
    # """
    if ! koopa_is_array_non_empty "$@"
    then
        koopa_stop 'Array is empty.'
    fi
    return 0
}
