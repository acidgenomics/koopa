#!/usr/bin/env bash

koopa_strip_trailing_slash() {
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2022-07-15.
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
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    koopa_strip_right --pattern='/' "$@"
    return 0
}
