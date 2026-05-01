#!/usr/bin/env bash

_koopa_line_count() {
    # """
    # Return the number of lines in a file.
    # @note Updated 2023-04-05.
    #
    # Example: _koopa_line_count 'tx2gene.csv'
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['wc']="$(_koopa_locate_wc)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        str="$( \
            "${app['wc']}" --lines "$file" \
                | "${app['xargs']}" \
                | "${app['cut']}" -d ' ' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}
