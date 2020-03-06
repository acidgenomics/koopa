#!/usr/bin/env bash

_koopa_assert_is_array_non_empty() {  # {{{1
    # """
    # Assert that array is non-empty.
    # @note Updated 2020-03-06.
    # """
    if ! _koopa_is_array_non_empty "$@"
    then
        _koopa_stop "Array is empty."
    fi
    return 0
}
