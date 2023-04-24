#!/usr/bin/env bash

koopa_progress_bar() {
    # """
    # Progress bar.
    # @note Updated 2023-04-24.
    #
    # @seealso
    # - https://www.baeldung.com/linux/command-line-progress-bar
    #
    # @examples
    # > koopa_progress_bar 25 100
    # # Progress [##########------------------------------] 25.0%
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    [[ "${COLUMNS:?}" -lt 40 ]] && return 0
    app['bc']="$(koopa_locate_bc)"
    app['echo']="$(koopa_locate_echo)"
    app['tr']="$(koopa_locate_tr)"
    koopa_assert_is_executable "${app[@]}"
    dict['bar_char_done']='#'
    dict['bar_char_todo']='-'
    dict['bar_pct_scale']=1
    dict['bar_size']="$((COLUMNS-20))"
    dict['current']="${1:?}"
    dict['total']="${2:?}"
    # Calculate the progress in percentage.
    dict['percent']="$( \
        "${app['bc']}" <<< \
            "scale=${dict['bar_pct_scale']}; \
            100 * ${dict['current']} / ${dict['total']}" \
    )"
    # Ensure decimals contain a leading zero when applicable.
    dict['percent_str']="$( \
        printf "%0.${dict['bar_pct_scale']}f" "${dict['percent']}"
    )"
    # The number of 'done' and 'todo' characters.
    dict['done']="$( \
        "${app['bc']}" <<< \
            "scale=0; \
            ${dict['bar_size']} * ${dict['percent']} / 100" \
    )"
    dict['todo']="$( \
        "${app['bc']}" <<< \
            "scale=0; ${dict['bar_size']} - ${dict['done']}" \
    )"
    # Build the 'done' and 'todo' sub-bars.
    dict['done_sub_bar']=$( \
        printf "%${dict['done']}s" | \
        "${app['tr']}" ' ' "${dict['bar_char_done']}" \
    )
    dict['todo_sub_bar']=$( \
        printf "%${dict['todo']}s" \
        | "${app['tr']}" ' ' "${dict['bar_char_todo']}" \
    )
    # Print the progress bar in stderr.
    >&2 "${app['echo']}" -ne "\rProgress \
[${dict['done_sub_bar']}${dict['todo_sub_bar']}] ${dict['percent_str']}%"
    if [[ "${dict['total']}" -eq "${dict['current']}" ]]
    then
        koopa_alert_success '\nDONE!'
    fi
    return 0
}
