#!/usr/bin/env bash

_koopa_macos_ifactive() {
    # """
    # Display active interfaces.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    app['ifconfig']="$(_koopa_macos_locate_ifconfig)"
    app['pcregrep']="$(_koopa_locate_pcregrep)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['ifconfig']}" \
            | "${app['pcregrep']}" -M -o \
                '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
