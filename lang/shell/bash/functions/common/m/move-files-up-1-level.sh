#!/usr/bin/env bash

koopa_move_files_up_1_level() {
    # """
    # Move files up 1 level.
    # @note Updated 2022-02-16.
    #
    # @examples
    # > koopa_touch 'a/aa/aaa.txt'
    # > koopa_move_files_up_1_level 'a/'
    # # Silent, but returns this structure:
    # # 'a/aa'
    # # 'a/aaa.txt'
    # """
    local dict files
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --type='f' \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict[prefix]}" "${files[@]}"
    return 0
}
