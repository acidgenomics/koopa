#!/usr/bin/env bash

_koopa_linux_os_version() {
    # """
    # Linux OS version.
    # @note Updated 2023-04-05.
    #
    # @seealso
    # - Refer to 'uname -r' for Linux kernel version information.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['key']='VERSION_ID'
    dict['file']='/etc/os-release'
    dict['string']="$( \
        "${app['awk']}" -F= \
            "\$1==\"${dict['key']}\" { print \$2 ;}" \
            "${dict['file']}" \
        | "${app['tr']}" -d '"' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}
