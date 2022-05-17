#!/usr/bin/env bash

koopa_check_access_human() {
    # """
    # Check if file or directory has expected human readable access.
    # @note Updated 2021-01-31.
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
    dict[access]="$(koopa_stat_access_human "${dict[file]}")"
    if [[ "${dict[access]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current access '${dict[access]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}
