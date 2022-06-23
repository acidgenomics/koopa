#!/bin/sh

__koopa_remove_from_path_string() {
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2022-06-23.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/145402/
    # """
    local dir str
    str="${1:?}"
    dir="${2:?}"
    koopa_print "$str" \
        | sed \
            -e "s|^${dir}:||g" \
            -e "s|:${dir}:|:|g" \
            -e "s|:${dir}\$||g"
    return 0
}
