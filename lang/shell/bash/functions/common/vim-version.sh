#!/usr/bin/env bash

koopa_vim_version() {
    # """
    # Vim version.
    # @note Updated 2022-03-18.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [vim]="${1:-}"
    )
    [[ -z "${app[vim]}" ]] && app[vim]="$(koopa_locate_vim)"
    declare -A dict=(
        [str]="$("${app[vim]}" --version 2>/dev/null)"
    )
    dict[maj_min]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '5' \
    )"
    dict[out]="${dict[maj_min]}"
    if koopa_str_detect_fixed \
        --string="${dict[str]}" \
        --pattern='Included patches:'
    then
        dict[patch]="$( \
            koopa_print "${dict[str]}" \
                | koopa_grep --pattern='Included patches:' \
                | "${app[cut]}" -d '-' -f '2' \
                | "${app[cut]}" -d ',' -f '1' \
        )"
        dict[out]="${dict[out]}.${dict[patch]}"
    fi
    koopa_print "${dict[out]}"
    return 0
}
