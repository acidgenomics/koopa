#!/usr/bin/env bash

koopa_mem_gb() {
    # """
    # Get total system memory in GB.
    # @note Updated 2023-05-30.
    #
    # - 1 GB / 1024 MB
    # - 1 MB / 1024 KB
    # - 1 KB / 1024 bytes
    #
    # Usage of 'int()' in awk rounds down.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    dict['str']="${KOOPA_MEM_GB:-}"
    if [[ -n "${dict['str']}" ]]
    then
        koopa_print "${dict['str']}"
        return 0
    fi
    app['awk']="$(koopa_locate_awk --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_macos
    then
        app['sysctl']="$(koopa_macos_locate_sysctl)"
        koopa_assert_is_executable "${app['sysctl']}"
        dict['mem']="$("${app['sysctl']}" -n 'hw.memsize')"
        dict['denom']=1073741824  # 1024^3; bytes
    elif koopa_is_linux
    then
        dict['meminfo']='/proc/meminfo'
        koopa_assert_is_file "${dict['meminfo']}"
        # shellcheck disable=SC2016
        dict['mem']="$( \
            "${app['awk']}" '/MemTotal/ {print $2}' "${dict['meminfo']}" \
        )"
        dict['denom']=1048576  # 1024^2; KB
    else
        koopa_stop 'Unsupported system.'
    fi
    dict['str']="$( \
        "${app['awk']}" \
            -v denom="${dict['denom']}" \
            -v mem="${dict['mem']}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
