#!/usr/bin/env bash

_koopa_current_wormbase_version() {
    # """
    # Current WormBase version.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_current_wormbase_version
    # # WS283
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    dict['string']="$( \
        _koopa_parse_url --list-only "${dict['url']}/" \
            | _koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app['cut']}" -d '.' -f '2' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}
