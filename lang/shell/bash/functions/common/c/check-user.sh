#!/usr/bin/env bash

koopa_check_user() {
    # """
    # Check if file or directory is owned by an expected user.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [file]="${1:?}"
        [expected_user]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist on disk."
        return 1
    fi
    dict[file]="$(koopa_realpath "${dict[file]}")"
    dict[current_user]="$(koopa_stat_user "${dict[file]}")"
    if [[ "${dict[current_user]}" != "${dict[expected_user]}" ]]
    then
        koopa_warn "'${dict[file]}' user '${dict[current_user]}' \
is not '${dict[expected_user]}'."
        return 1
    fi
    return 0
}
