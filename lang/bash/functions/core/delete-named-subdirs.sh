#!/usr/bin/env bash

_koopa_delete_named_subdirs() {
    # """
    # Delete named subdirectories.
    # @note Updated 2021-11-04.
    # """
    local -A dict
    local -a matches
    _koopa_assert_has_args_eq "$#" 2
    dict['prefix']="${1:?}"
    dict['subdir_name']="${2:?}"
    readarray -t matches <<< "$( \
        _koopa_find \
            --pattern="${dict['subdir_name']}" \
            --prefix="${dict['prefix']}" \
            --type='d' \
    )"
    _koopa_is_array_non_empty "${matches[@]:-}" || return 1
    _koopa_print "${matches[@]}"
    _koopa_rm "${matches[@]}"
    return 0
}
