#!/usr/bin/env bash

koopa_tex_version() {
    # """
    # TeX version (release year).
    # @note Updated 2023-04-05.
    #
    # @section Release year parsing:
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local -A app
    local str
    koopa_assert_has_args_le "$#" 1
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['tex']="${1:-}"
    [[ -z "${app['tex']}" ]] && app['tex']="$(koopa_locate_tex)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['tex']}" --version \
            | "${app['head']}" -n 1 \
            | "${app['cut']}" -d '(' -f '2' \
            | "${app['cut']}" -d ')' -f '1' \
            | "${app['cut']}" -d ' ' -f '3' \
            | "${app['cut']}" -d '/' -f '1' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
