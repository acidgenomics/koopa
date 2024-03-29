#!/usr/bin/env bash

koopa_list_path_priority() {
    # """
    # List path priority.
    # @note Updated 2023-03-13.
    # """
    local -A app dict
    local -a all_arr unique_arr
    koopa_assert_has_args_le "$#" 1
    app['awk']="$(koopa_locate_awk)"
    koopa_assert_is_executable "${app[@]}"
    dict['string']="${1:-$PATH}"
    readarray -t all_arr <<< "$( \
        koopa_print "${dict['string']//:/$'\n'}" \
    )"
    koopa_is_array_non_empty "${all_arr[@]:-}" || return 1
    # shellcheck disable=SC2016
    readarray -t unique_arr <<< "$( \
        koopa_print "${all_arr[@]}" \
            | "${app['awk']}" '!a[$0]++' \
    )"
    koopa_is_array_non_empty "${unique_arr[@]:-}" || return 1
    dict['n_all']="${#all_arr[@]}"
    dict['n_unique']="${#unique_arr[@]}"
    dict['n_dupes']="$((dict['n_all'] - dict['n_unique']))"
    if [[ "${dict['n_dupes']}" -gt 0 ]]
    then
        koopa_alert_note "$(koopa_ngettext \
            --num="${dict['n_dupes']}" \
            --msg1='duplicate' \
            --msg2='duplicates' \
            --suffix=' detected.' \
        )"
    fi
    koopa_print "${all_arr[@]}"
    return 0
}
