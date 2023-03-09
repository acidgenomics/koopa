#!/bin/sh

_koopa_add_to_path_string_start() {
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2022-08-29.
    #
    # @seealso
    # - https://stackoverflow.com/questions/35693980/
    # """
    local dir str
    str="${1:-}"
    dir="${2:?}"
    if _koopa_str_detect_posix "$str" "${dir}:"
    then
        str="$(_koopa_remove_from_path_string "$str" "${dir}")"
    fi
    if [ -z "$str" ]
    then
        str="$dir"
    else
        str="${dir}:${str}"
    fi
    _koopa_print "$str"
    return 0
}
