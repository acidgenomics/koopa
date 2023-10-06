#!/usr/bin/env bash

koopa_uninstall_koopa() {
    # """
    # Uninstall koopa.
    # @note Updated 2022-04-08.
    # """
    local -A dict
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    # FIXME Prompt the user that they want to continue.
    if koopa_is_linux && koopa_is_shared_install
    then
        koopa_rm --sudo '/etc/profile.d/zzz-koopa.sh'
    fi
    koopa_uninstall_dotfiles
    # FIXME Consider passing --verbose flag here, for better progress.
    # FIXME Pass '--sudo' for non shared install.
    koopa_rm \
        "${dict['config_prefix']}" \
        "${dict['koopa_prefix']}"
    return 0
}
