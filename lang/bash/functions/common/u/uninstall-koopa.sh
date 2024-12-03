#!/usr/bin/env bash

koopa_uninstall_koopa() {
    # """
    # Uninstall koopa.
    # @note Updated 2024-12-03.
    # """
    local -A bool dict
    bool['uninstall_koopa']=1
    dict['bootstrap_prefix']="$(koopa_bootstrap_prefix)"
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
    koopa_rm --verbose \
        "${dict['bootstrap_prefix']}" \
        "${dict['config_prefix']}"
    if koopa_is_shared_install && koopa_is_admin
    then
        if koopa_is_linux
        then
            dict['profile_d_file']="$(koopa_linux_profile_d_file)"
            koopa_rm --sudo --verbose "${dict['profile_d_file']}"
        fi
        koopa_rm --sudo --verbose "${dict['koopa_prefix']}"
    else
        koopa_rm --verbose "${dict['koopa_prefix']}"
    fi
    return 0
}
