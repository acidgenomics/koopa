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
    local -A app
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['tail']="$(koopa_locate_tail --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app['tail']}" -n 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
