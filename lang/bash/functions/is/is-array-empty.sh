#!/usr/bin/env bash

_koopa_is_array_empty() {
    # """
    # Is the array input empty?
    # @note Updated 2020-12-03.
    # """
    ! _koopa_is_array_non_empty "$@"
}
