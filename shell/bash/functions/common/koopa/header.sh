#!/usr/bin/env bash

koopa::header() { # {{{1
    # """
    # Source script header.
    # @note Updated 2020-09-11.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local arg ext file koopa_prefix subdir
    koopa::assert_has_args_eq "$#" 1
    arg="$(koopa::lowercase "${1:?}")"
    koopa_prefix="$(koopa::prefix)"
    case "$arg" in
        bash|posix|zsh)
            subdir='shell'
            ext='sh'
            ;;
        # > python)
        # >     subdir='lang'
        # >     ext='py'
        # >     ;;
        r)
            subdir='lang'
            ext='R'
            ;;
        *)
            koopa::invalid_arg "$arg"
            ;;
    esac
    file="${koopa_prefix}/${subdir}/${arg}/include/header.${ext}"
    koopa::assert_is_file "$file"
    koopa::print "$file"
    return 0
}
