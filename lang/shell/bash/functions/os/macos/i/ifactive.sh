#!/usr/bin/env bash

koopa_macos_ifactive() {
    # """
    # Display active interfaces.
    # @note Updated 2022-10-06.
    # """
    local app x
    declare -A app=(
        ['ifconfig']="$(koopa_macos_locate_ifconfig)"
        ['pcregrep']="$(koopa_locate_pcregrep)"
    )
    [[ -x "${app['ifconfig']}" ]] || exit 1
    [[ -x "${app['pcregrep']}" ]] || exit 1
    x="$( \
        "${app['ifconfig']}" \
            | "${app['pcregrep']}" -M -o \
                '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
