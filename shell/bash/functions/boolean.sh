#!/usr/bin/env bash

_koopa_is_array_non_empty() {  # {{{1
    # """
    # Is the array non-empty?
    # @note Updated 2019-10-22.
    #
    # Particularly useful for checking against mapfile return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    # """
    local arr
    arr=("$@")
    [[ "${#arr[@]}" -eq 0 ]] && return 1
    [[ -z "${arr[0]}" ]] && return 1
    return 0
}
