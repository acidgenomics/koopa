#!/usr/bin/env bash

_koopa_list_path_priority() {
    # """
    # List path priority.
    # @note Updated 2023-03-13.
    # """
    local -A app dict
    local -a all_arr unique_arr
    _koopa_assert_has_args_le "$#" 1
    app['awk']="$(_koopa_locate_awk)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="${1:-$PATH}"
    readarray -t all_arr <<< "$( \
        _koopa_print "${dict['string']//:/$'\n'}" \
    )"
    _koopa_is_array_non_empty "${all_arr[@]:-}" || return 1
    # shellcheck disable=SC2016
    readarray -t unique_arr <<< "$( \
        _koopa_print "${all_arr[@]}" \
            | "${app['awk']}" '!a[$0]++' \
    )"
    _koopa_is_array_non_empty "${unique_arr[@]:-}" || return 1
    dict['n_all']="${#all_arr[@]}"
    dict['n_unique']="${#unique_arr[@]}"
    dict['n_dupes']="$((dict['n_all'] - dict['n_unique']))"
    if [[ "${dict['n_dupes']}" -gt 0 ]]
    then
        _koopa_alert_note "$(_koopa_ngettext \
            --num="${dict['n_dupes']}" \
            --msg1='duplicate' \
            --msg2='duplicates' \
            --suffix=' detected.' \
        )"
    fi
    _koopa_print "${all_arr[@]}"
    return 0
}
