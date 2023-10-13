#!/usr/bin/env bash

koopa_uninstall_koopa() {
    # """
    # Uninstall koopa.
    # @note Updated 2023-10-13.
    # """
    local -A bool dict
    bool['uninstall_koopa']=1
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    if koopa_is_interactive
    then
        bool['uninstall_koopa']="$( \
            koopa_read_yn \
                'Proceed with koopa uninstall' \
                "${bool['uninstall_koopa']}" \
        )"
    fi
    [[ "${bool['uninstall_koopa']}" -eq 0 ]] && return 1
    koopa_rm --verbose "${dict['config_prefix']}"
    if koopa_is_shared_install
    then
        if koopa_is_linux
        then
            koopa_rm --sudo --verbose '/etc/profile.d/zzz-koopa.sh'
        fi
        koopa_rm --sudo --verbose "${dict['koopa_prefix']}"
    else
        koopa_rm --verbose "${dict['koopa_prefix']}"
    fi
    return 0
}
