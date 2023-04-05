#!/usr/bin/env bash

koopa_linux_os_version() {
    # """
    # Linux OS version.
    # @note Updated 2023-01-10.
    #
    # @seealso
    # - Refer to 'uname -r' for Linux kernel version information.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    local -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['tr']="$(koopa_locate_tr --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['tr']}" ]] || exit 1
    local -A dict=(
        ['key']='VERSION_ID'
        ['file']='/etc/os-release'
    )
    dict['string']="$( \
        "${app['awk']}" -F= \
            "\$1==\"${dict['key']}\" { print \$2 ;}" \
            "${dict['file']}" \
        | "${app['tr']}" -d '"' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
