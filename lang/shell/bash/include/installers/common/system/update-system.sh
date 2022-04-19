#!/usr/bin/env bash

# FIXME How is this different than 'koopa configure system'?
# FIXME Need to rethink this...
# FIXME How to make a versioned install of Google Cloud SDK?
# FIXME Need to update Doom Emacs, Spacemacs, Prelude Emacs, Chemacs2...

main() { # {{{1
    # """
    # Update system.
    # @note Updated 2022-04-19.
    # """
    local dict
    declare -A dict=(
        [config_prefix]="$(koopa_config_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    koopa_update_koopa
    koopa_dl \
        'Config prefix' "${dict[config_prefix]}" \
        'Make prefix' "${dict[make_prefix]}" \
        'Opt prefix' "${dict[opt_prefix]}"
    koopa_add_make_prefix_link
    if koopa_is_linux
    then
        koopa_linux_update_etc_profile_d
        koopa_linux_update_ldconfig
        koopa_configure_system --no-check
    fi
    koopa_update_google_cloud_sdk
    koopa_update_perlbrew
    koopa_update_pyenv
    koopa_update_rbenv
    koopa_update_r_packages
    koopa_update_rust
    koopa_update_rust_packages
    if koopa_is_macos
    then
        koopa_macos_update_defaults
        koopa_macos_update_microsoft_office || true
    fi
    return 0
}
