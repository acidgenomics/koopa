#!/bin/sh

_koopa_add_to_path_string_end() {
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2023-03-10.
    # """
    __kvar_string="${1:-}"
    __kvar_dir="${2:?}"
    if _koopa_str_detect_posix "$__kvar_string" ":${__kvar_dir}"
    then
        __kvar_string="$(\
            _koopa_remove_from_path_string \
                "$__kvar_string" ":${__kvar_dir}" \
        )"
    fi
    if [ -z "$__kvar_string" ]
    then
        __kvar_string="$__kvar_dir"
    else
        __kvar_string="${__kvar_string}:${__kvar_dir}"
    fi
    _koopa_print "$__kvar_string"
    unset -v \
        __kvar_dir \
        __kvar_string
    return 0
}
