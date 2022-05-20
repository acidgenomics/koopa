#!/usr/bin/env bash

koopa_check_group() {
    # """
    # Check if file or directory has an expected group.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[group]="$(koopa_stat_group "${dict[file]}")"
    if [[ "${dict[group]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current group '${dict[group]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}
