#!/usr/bin/env bash

koopa_check_mount() {
    # """
    # Check if a drive is mounted.
    # @note Updated 2022-01-31.
    #
    # @examples
    # > koopa_check_mount '/mnt/scratch'
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [wc]="$(koopa_locate_wc)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    if [[ ! -r "${dict[prefix]}" ]] || [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_warn "'${dict[prefix]}' is not a readable directory."
        return 1
    fi
    dict[nfiles]="$( \
        koopa_find \
            --prefix="${dict[prefix]}" \
            --min-depth=1 \
            --max-depth=1 \
        | "${app[wc]}" -l \
    )"
    if [[ "${dict[nfiles]}" -eq 0 ]]
    then
        koopa_warn "'${dict[prefix]}' is unmounted and/or empty."
        return 1
    fi
    return 0
}
