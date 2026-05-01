#!/usr/bin/env bash

_koopa_delete_empty_dirs() {
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
    # > _koopa_mkdir 'a/aa/aaa/aaaa' 'b/bb/bbb/bbbb'
    # > _koopa_delete_empty_dirs 'a' 'b'
    # """
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(_koopa_find_empty_dirs "$prefix")" ]]
        do
            local -a dirs
            local dir
            readarray -t dirs <<< "$(_koopa_find_empty_dirs "$prefix")"
            _koopa_is_array_non_empty "${dirs[@]:-}" || continue
            for dir in "${dirs[@]}"
            do
                [[ -d "$dir" ]] || continue
                _koopa_alert "Deleting '${dir}'."
                _koopa_rm "$dir"
            done
        done
    done
    return 0
}
