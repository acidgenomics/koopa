#!/bin/sh

_koopa_remove_from_path_string() {
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2022-08-29.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/145402/
    #
    # @examples
    # > _koopa_remove_from_path_string \
    # >     '/usr/local/bin:/usr/bin' \
    # >     '/usr/local/bin'
    # > _koopa_remove_from_path_string \
    # >     '/usr/local/bin:/usr/bin' \
    # >     '/usr/bin'
    # """
    local dir str1 str2
    str1="${1:?}"
    dir="${2:?}"
    str2="$( \
        _koopa_print "$str1" \
            | sed \
                -e "s|^${dir}:||g" \
                -e "s|:${dir}:|:|g" \
                -e "s|:${dir}\$||g" \
        )"
    [ -n "$str2" ] || return 1
    _koopa_print "$str2"
    return 0
}
