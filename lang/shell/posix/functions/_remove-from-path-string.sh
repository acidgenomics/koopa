#!/bin/sh

__koopa_remove_from_path_string() { # {{{1
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2022-04-17.
    #
    # Alternative non-POSIX approach that works on Bash and Zsh:
    # > PATH="${PATH//:$dir/}"
    # """
    koopa_print "${1:?}" | sed "s|${2:?}||g"
    return 0
}
