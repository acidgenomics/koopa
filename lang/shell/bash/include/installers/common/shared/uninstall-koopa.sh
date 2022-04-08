#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall koopa.
    # @note Updated 2022-04-08.
    # """
    local dict
    declare -A dict=(
        [config_prefix]="$(koopa_config_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    if koopa_is_linux && koopa_is_shared_install
    then
        koopa_rm --sudo '/etc/profile.d/zzz-koopa.sh'
    fi
    koopa_uninstall_dotfiles
    koopa_rm \
        "${dict[config_prefix]}" \
        "${dict[koopa_prefix]}"
    return 0
}
