#!/usr/bin/env bash

# FIXME Work on adding support for macOS screenshots:
# Screenshot YYYY-MM-DD at H.M.S AM.png

koopa_move_into_dated_dirs_by_filename() {
    # """
    # Move into dated directories by filename.
    # @note Updated 2023-04-06.
    # """
    local -a grep_array
    local file grep_string
    koopa_assert_has_args "$#"
    grep_array=(
        '^([0-9]{4})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '(.+)$'
    )
    grep_string="$(koopa_paste0 "${grep_array[@]}")"
    for file in "$@"
    do
        local -A dict
        dict['file']="$file"
        # NOTE Don't quote '$grep_string' here.
        if [[ "${dict['file']}" =~ $grep_string ]]
        then
            dict['year']="${BASH_REMATCH[1]}"
            dict['month']="${BASH_REMATCH[3]}"
            dict['day']="${BASH_REMATCH[5]}"
            dict['subdir']="${dict['year']}/${dict['month']}/${dict['day']}"
            koopa_mv --target-directory="${dict['subdir']}" "${dict['file']}"
        else
            koopa_stop "Does not contain date: '${dict['file']}'."
        fi
    done
    return 0
}
