#!/bin/sh

__koopa_remove_from_path_string() {
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2022-08-29.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/145402/
    #
    # @examples
    # > __koopa_remove_from_path_string \
    # >     '/usr/local/bin:/usr/bin' \
    # >     '/usr/local/bin'
    # > __koopa_remove_from_path_string \
    # >     '/usr/local/bin:/usr/bin' \
    # >     '/usr/bin'
    # """
    local dir str1 str2
    str1="${1:?}"
    dir="${2:?}"
    str2="$( \
        koopa_print "$str1" \
            | sed \
                -e "s|^${dir}:||g" \
                -e "s|:${dir}:|:|g" \
                -e "s|:${dir}\$||g" \
        )"
    [ -n "$str2" ] || return 1
    koopa_print "$str2"
    return 0
}
