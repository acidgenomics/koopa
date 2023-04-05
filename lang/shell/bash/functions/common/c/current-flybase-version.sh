#!/usr/bin/env bash

koopa_current_flybase_version() {
    # """
    # Current FlyBase version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_flybase_version
    # # FB2022_01
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['tail']="$(koopa_locate_tail --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || exit 1
    [[ -x "${app['head']}" ]] || exit 1
    [[ -x "${app['tail']}" ]] || exit 1
    str="$( \
        koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app['tail']}" -n 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
