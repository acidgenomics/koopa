#!/usr/bin/env bash

koopa_delete_named_subdirs() {
    # """
    # Delete named subdirectories.
    # @note Updated 2021-11-04.
    # """
    local -A dict
    local -a matches
    koopa_assert_has_args_eq "$#" 2
    dict['prefix']="${1:?}"
    dict['subdir_name']="${2:?}"
    readarray -t matches <<< "$( \
        koopa_find \
            --pattern="${dict['subdir_name']}" \
            --prefix="${dict['prefix']}" \
            --type='d' \
    )"
    koopa_is_array_non_empty "${matches[@]:-}" || return 1
    koopa_print "${matches[@]}"
    koopa_rm "${matches[@]}"
    return 0
}
