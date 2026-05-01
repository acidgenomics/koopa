#!/usr/bin/env bash

_koopa_strip_trailing_slash() {
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2022-07-15.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @usage _koopa_strip_trailing_slash STRING...
    #
    # @examples
    # > _koopa_strip_trailing_slash './dir1/' './dir2/'
    # # ./dir1
    # # ./dir2
    # """
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    _koopa_strip_right --pattern='/' "$@"
    return 0
}
