#!/usr/bin/env bash

koopa_mem_gb() {
    # """
    # Get total system memory in GB.
    # @note Updated 2022-02-09.
    #
    # - 1 GB / 1024 MB
    # - 1 MB / 1024 KB
    # - 1 KB / 1024 bytes
    #
    # Usage of 'int()' in awk rounds down.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]='awk'
    )
    declare -A dict
    if koopa_is_macos
    then
        app[sysctl]="$(koopa_macos_locate_sysctl)"
        dict[mem]="$("${app[sysctl]}" -n 'hw.memsize')"
        dict[denom]=1073741824  # 1024^3; bytes
    elif koopa_is_linux
    then
        dict[meminfo]='/proc/meminfo'
        koopa_assert_is_file "${dict[meminfo]}"
        # shellcheck disable=SC2016
        dict[mem]="$("${app[awk]}" '/MemTotal/ {print $2}' "${dict[meminfo]}")"
        dict[denom]=1048576  # 1024^2; KB
    else
        koopa_stop 'Unsupported system.'
    fi
    dict[str]="$( \
        "${app[awk]}" \
            -v denom="${dict[denom]}" \
            -v mem="${dict[mem]}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
