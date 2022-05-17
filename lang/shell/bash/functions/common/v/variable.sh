#!/usr/bin/env bash

koopa_variable() {
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2022-03-09.
    #
    # This approach handles inline comments.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [key]="${1:?}"
        [include_prefix]="$(koopa_include_prefix)"
    )
    dict[file]="${dict[include_prefix]}/variables.txt"
    koopa_assert_is_file "${dict[file]}"
    dict[str]="$( \
        koopa_grep \
            --file="${dict[file]}" \
            --only-matching \
            --pattern="^${dict[key]}=\"[^\"]+\"" \
            --regex \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    dict[str]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '"' -f '2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
