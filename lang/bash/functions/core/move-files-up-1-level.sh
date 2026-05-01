#!/usr/bin/env bash

_koopa_move_files_up_1_level() {
    # """
    # Move files up 1 level.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > _koopa_touch 'a/aa/aaa.txt'
    # > _koopa_move_files_up_1_level 'a/'
    # # Silent, but returns this structure:
    # # 'a/aa'
    # # 'a/aaa.txt'
    # """
    local -A dict
    local -a files
    _koopa_assert_has_args_le "$#" 1
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    readarray -t files <<< "$( \
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict['prefix']}" \
            --type='f' \
    )"
    _koopa_is_array_non_empty "${files[@]:-}" || return 1
    _koopa_mv --target-directory="${dict['prefix']}" "${files[@]}"
    return 0
}
