#!/usr/bin/env bash

koopa_local_ip_address() {
    # """
    # Local IP address.
    # @note Updated 2022-02-09.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [head]="$(koopa_locate_head)"
        [tail]="$(koopa_locate_tail)"
    )
    if koopa_is_macos
    then
        app[ifconfig]="$(koopa_macos_locate_ifconfig)"
        # shellcheck disable=SC2016
        str="$( \
            "${app[ifconfig]}" \
            | koopa_grep --pattern='inet ' \
            | koopa_grep --pattern='broadcast' \
            | "${app[awk]}" '{print $2}' \
            | "${app[tail]}" -n 1 \
        )"
    else
        app[hostname]="$(koopa_locate_hostname)"
        # shellcheck disable=SC2016
        str="$( \
            "${app[hostname]}" -I \
            | "${app[awk]}" '{print $1}' \
            | "${app[head]}" -n 1 \
        )"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
