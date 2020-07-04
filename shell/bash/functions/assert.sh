#!/usr/bin/env bash

koopa::assert_is_array_non_empty() { # {{{1
    # """
    # Assert that array is non-empty.
    # @note Updated 2020-03-06.
    # """
    if ! koopa::is_array_non_empty "$@"
    then
        koopa::stop "Array is empty."
    fi
    return 0
}
