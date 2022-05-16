#!/usr/bin/env bash

koopa_is_array_non_empty() {
    # """
    # Is the array non-empty?
    # @note Updated 2021-08-31.
    #
    # Particularly useful for checking against readarray return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    #
    # @seealso
    # - https://serverfault.com/questions/477503/
    # """
    local arr
    [[ "$#" -gt 0 ]] || return 1
    arr=("$@")
    [[ "${#arr[@]}" -gt 0 ]] || return 1
    [[ -n "${arr[0]}" ]] || return 1
    return 0
}
