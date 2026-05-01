#!/usr/bin/env bash

_koopa_uninstall_koopa() {
    # """
    # Uninstall koopa.
    # @note Updated 2024-12-03.
    # """
    local -A bool dict
    bool['uninstall_koopa']=1
    dict['bootstrap_prefix']="$(_koopa_bootstrap_prefix)"
    dict['config_prefix']="$(_koopa_config_prefix)"
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    if _koopa_is_interactive
    then
        bool['uninstall_koopa']="$( \
            _koopa_read_yn \
                'Proceed with koopa uninstall' \
                "${bool['uninstall_koopa']}" \
        )"
    fi
    [[ "${bool['uninstall_koopa']}" -eq 0 ]] && return 1
    _koopa_rm --verbose \
        "${dict['bootstrap_prefix']}" \
        "${dict['config_prefix']}"
    if _koopa_is_shared_install && _koopa_is_admin
    then
        if _koopa_is_linux
        then
            dict['profile_d_file']="$(_koopa_linux_profile_d_file)"
            _koopa_rm --sudo --verbose "${dict['profile_d_file']}"
        fi
        _koopa_rm --sudo --verbose "${dict['koopa_prefix']}"
    else
        _koopa_rm --verbose "${dict['koopa_prefix']}"
    fi
    return 0
}
