#!/usr/bin/env bash

koopa_tex_version() {
    # """
    # TeX version (release year).
    # @note Updated 2022-03-18.
    #
    # @section Release year parsing:
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    local -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['tex']="${1:-}"
    )
    [[ -z "${app['tex']}" ]] && app['tex']="$(koopa_locate_tex)"
    [[ -x "${app['cut']}" ]] || exit 1
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['tex']}" ]] || exit 1
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
