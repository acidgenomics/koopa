#!/bin/sh

__koopa_add_to_path_string_end() { # {{{1
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2022-04-17.
    # """
    local dir str
    str="${1:-}"
    dir="${2:?}"
    if koopa_str_detect_posix "$str" ":${dir}"
    then
        str="$(__koopa_remove_from_path_string "$str" ":${dir}")"
    fi
    if [ -z "$str" ]
    then
        str="$dir"
    else
        str="${str}:${dir}"
    fi
    koopa_print "$str"
    return 0
}
