#!/usr/bin/env bash

koopa_current_wormbase_version() {
    # """
    # Current WormBase version.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_current_wormbase_version
    # # WS283
    # """
    local app dict
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    [[ -x "${app['cut']}" ]] || exit 1
    dict['url']="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    dict['string']="$( \
        koopa_parse_url --list-only "${dict['url']}/" \
            | koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app['cut']}" -d '.' -f '2' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
