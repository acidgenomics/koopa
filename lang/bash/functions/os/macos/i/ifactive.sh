#!/usr/bin/env bash

koopa_macos_ifactive() {
    # """
    # Display active interfaces.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    app['ifconfig']="$(koopa_macos_locate_ifconfig)"
    app['pcregrep']="$(koopa_locate_pcregrep)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['ifconfig']}" \
            | "${app['pcregrep']}" -M -o \
                '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
