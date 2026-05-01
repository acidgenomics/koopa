#!/usr/bin/env bash

_koopa_current_flybase_version() {
    # """
    # Current FlyBase version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > _koopa_current_flybase_version
    # # FB2022_01
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['tail']="$(_koopa_locate_tail --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | _koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app['tail']}" -n 1 \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
