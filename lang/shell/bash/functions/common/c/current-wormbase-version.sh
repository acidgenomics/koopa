#!/usr/bin/env bash

koopa_current_wormbase_version() {
    # """
    # Current WormBase version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_wormbase_version
    # # WS283
    # """
    local app str url
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    str="$( \
        koopa_parse_url --list-only "${url}/" \
            | koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app[cut]}" -d '.' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
