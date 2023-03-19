#!/bin/sh

_koopa_remove_from_path_string() {
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2023-03-11.
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
    __kvar_str1="${1:?}"
    __kvar_dir="${2:?}"
    __kvar_str2="$( \
        _koopa_print "$__kvar_str1" \
            | sed \
                -e "s|^${__kvar_dir}:||g" \
                -e "s|:${__kvar_dir}:|:|g" \
                -e "s|:${__kvar_dir}\$||g" \
        )"
    [ -n "$__kvar_str2" ] || return 1
    _koopa_print "$__kvar_str2"
    unset -v \
        __kvar_dir \
        __kvar_str1 \
        __kvar_str2
    return 0
}
