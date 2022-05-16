#!/usr/bin/env bash

koopa_strip_trailing_slash() {
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2022-03-01.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @usage koopa_strip_trailing_slash STRING...
    #
    # @examples
    # > koopa_strip_trailing_slash './dir1/' './dir2/'
    # # ./dir1
    # # ./dir2
    # """
    local args
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    koopa_strip_right --pattern='/' "${args[@]}"
    return 0
}
