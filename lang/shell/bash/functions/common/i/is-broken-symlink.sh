#!/usr/bin/env bash

koopa_is_broken_symlink() {
    # """
    # Is the input a non-existing symbolic link?
    # @note Updated 2022-08-12.
    # """
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        if [[ -L "$file" ]] && [[ ! -e "$file" ]]
        then
            continue
        fi
        return 1
    done
    return 0
}
