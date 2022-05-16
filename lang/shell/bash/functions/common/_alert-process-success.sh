#!/usr/bin/env bash

__koopa_alert_process_success() {
    # """
    # Inform the user about the successful completion of a process.
    # @note Updated 2022-03-09.
    # """
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 2
    dict[name]="${1:?}"
    dict[prefix]="${2:-}"
    if [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} of '${dict[name]}' at '${dict[prefix]}' \
was successful."
    else
        dict[out]="${dict[word]} of '${dict[name]}' was successful."
    fi
    koopa_alert_success "${dict[out]}"
    return 0
}
