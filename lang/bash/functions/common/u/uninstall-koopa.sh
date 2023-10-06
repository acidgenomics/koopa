#!/usr/bin/env bash

koopa_uninstall_koopa() {
    # """
    # Uninstall koopa.
    # @note Updated 2023-10-06.
    # """
    local -A bool dict
    bool['dotfiles']=1
    bool['koopa']=1
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    if koopa_is_interactive
    then
        bool['koopa']="$( \
            koopa_read_yn \
                'Proceed with koopa uninstall' \
                "${bool['koopa']}" \
        )"
        bool['dotfiles']="$( \
            koopa_read_yn \
                'Uninstall dotfiles' \
                "${bool['dotfiles']}" \
        )"
    fi
    [[ "${bool['koopa']}" -eq 0 ]] && return 1
    [[ "${bool['dotfiles']}" -eq 1 ]] && koopa_uninstall_dotfiles
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
