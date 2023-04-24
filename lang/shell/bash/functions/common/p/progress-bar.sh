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
    # # Progress : [##########------------------------------] 25.0%
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    app['bc']="$(koopa_locate_bc)"
    app['echo']="$(koopa_locate_echo)"
    app['tr']="$(koopa_locate_tr)"
    koopa_assert_is_executable "${app[@]}"
    dict['bar_char_done']='#'
    dict['bar_char_todo']='-'
    dict['bar_pct_scale']=1
    dict['bar_size']=40
    dict['current']="${1:?}"
    dict['total']="${2:?}"
    # Calculate the progress in percentage.
    dict['percent']="$( \
        "${app['bc']}" <<< \
            "scale=${dict['bar_pct_scale']}; \
            100 * ${dict['current']} / ${dict['total']}" \
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
    # Output the bar.
    "${app['echo']}" -ne "\rProgress : \
[${dict['done_sub_bar']}${dict['todo_sub_bar']}] ${dict['percent']}%"
    if [[ "${dict['total']}" -eq "${dict['current']}" ]]
    then
        "${app['echo']}" -e '\nDONE'
    fi
    return 0
}
