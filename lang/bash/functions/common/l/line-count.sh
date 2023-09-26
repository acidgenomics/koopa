#!/usr/bin/env bash

koopa_line_count() {
    # """
    # Return the number of lines in a file.
    # @note Updated 2023-04-05.
    #
    # Example: koopa_line_count 'txToGene.csv'
    # """
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['wc']="$(koopa_locate_wc)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        str="$( \
            "${app['wc']}" --lines "$file" \
                | "${app['xargs']}" \
                | "${app['cut']}" -d ' ' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
