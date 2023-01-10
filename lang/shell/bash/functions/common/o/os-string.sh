#!/usr/bin/env bash

koopa_os_string() {
    # """
    # Operating system string.
    # @note Updated 2023-01-10.
    #
    # Alternatively, use 'hostnamectl'.
    # https://linuxize.com/post/how-to-check-linux-version/
    #
    # If we ever add Windows support, look for: cygwin, mingw32*, msys*.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app dict
    if koopa_is_macos
    then
        dict['id']='macos'
        dict['version']="$(koopa_macos_os_version)"
        dict['version']="$(koopa_major_version "${dict['version']}")"
    elif koopa_is_linux
    then
        app['awk']="$(koopa_locate_awk --allow-system)"
        app['tr']="$(koopa_locate_tr --allow-system)"
        [[ -x "${app['awk']}" ]] || return 1
        [[ -x "${app['tr']}" ]] || return 1
        dict['release_file']='/etc/os-release'
        if [[ -r "${dict['release_file']}" ]]
        then
            dict['id']="$( \
                "${app['awk']}" -F= \
                    "\$1==\"ID\" { print \$2 ;}" \
                    "${dict['release_file']}" \
                | "${app['tr']}" -d '"' \
            )"
            # Include the major release version.
            dict['version']="$( \
                "${app['awk']}" -F= \
                    "\$1==\"VERSION_ID\" { print \$2 ;}" \
                    "${dict['release_file']}" \
                | "${app['tr']}" -d '"' \
            )"
            if [[ -n "${dict['version']}" ]]
            then
                dict['version']="$(koopa_major_version "${dict['version']}")"
            else
                # This is the case for Arch Linux.
                dict['version']='rolling'
            fi
        else
            dict['id']='linux'
        fi
    fi
    [[ -n "${dict['id']}" ]] || return 1
    dict['string']="${dict['id']}"
    if [[ -n "${dict['version']:-}" ]]
    then
        dict['string']="${dict['string']}-${dict['version']}"
    fi
    koopa_print "${dict['string']}"
    return 0
}
