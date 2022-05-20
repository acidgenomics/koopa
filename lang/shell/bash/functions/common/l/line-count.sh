#!/usr/bin/env bash

koopa_line_count() {
    # """
    # Return the number of lines in a file.
    # @note Updated 2022-02-16.
    #
    # Example: koopa_line_count 'tx2gene.csv'
    # """
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [wc]="$(koopa_locate_wc)"
        [xargs]="$(koopa_locate_xargs)"
    )
    for file in "$@"
    do
        str="$( \
            "${app[wc]}" --lines "$file" \
                | "${app[xargs]}" \
                | "${app[cut]}" -d ' ' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
