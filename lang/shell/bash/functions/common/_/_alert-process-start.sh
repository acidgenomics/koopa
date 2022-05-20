#!/usr/bin/env bash

__koopa_alert_process_start() {
    # """
    # Inform the user about the start of a process.
    # @note Updated 2022-04-08.
    # """
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 3
    dict[name]="${1:?}"
    dict[version]=''
    dict[prefix]=''
    if [[ "$#" -eq 2 ]]
    then
        dict[prefix]="${2:?}"
    elif [[ "$#" -eq 3 ]]
    then
        dict[version]="${2:?}"
        dict[prefix]="${3:?}"
    fi
    if [[ -n "${dict[prefix]}" ]] && [[ -n "${dict[version]}" ]]
    then
        dict[out]="${dict[word]} '${dict[name]}' ${dict[version]} \
at '${dict[prefix]}'."
    elif [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} '${dict[name]}' at '${dict[prefix]}'."
    else
        dict[out]="${dict[word]} '${dict[name]}'."
    fi
    koopa_alert "${dict[out]}"
    return 0
}
