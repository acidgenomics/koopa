#!/usr/bin/env bash

koopa_delete_empty_dirs() {
    # """
    # Delete empty directories.
    # @note Updated 2021-06-16.
    #
    # Don't pass a single call to 'rm' here, as argument list can be too
    # long to parse.
    #
    # @seealso
    # - While loop
    #   https://www.cyberciti.biz/faq/bash-while-loop/
    #
    # @examples
    # > koopa_mkdir 'a/aa/aaa/aaaa' 'b/bb/bbb/bbbb'
    # > koopa_delete_empty_dirs 'a' 'b'
    # """
    local dir dirs prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(koopa_find_empty_dirs "$prefix")" ]]
        do
            readarray -t dirs <<< "$(koopa_find_empty_dirs "$prefix")"
            koopa_is_array_non_empty "${dirs[@]:-}" || continue
            for dir in "${dirs[@]}"
            do
                [[ -d "$dir" ]] || continue
                koopa_alert "Deleting '${dir}'."
                koopa_rm "$dir"
            done
        done
    done
    return 0
}
