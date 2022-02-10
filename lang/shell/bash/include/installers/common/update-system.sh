#!/usr/bin/env bash

koopa:::update_system() { # {{{1
    # """
    # Update system.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa::assert_is_admin
    declare -A app=(
        [brew]="$(koopa::locate_brew 2>/dev/null || true)"
    )
    declare -A dict=(
        [config_prefix]="$(koopa::config_prefix)"
        [make_prefix]="$(koopa::make_prefix)"
        [opt_prefix]="$(koopa::opt_prefix)"
    )
    koopa::update_koopa
    koopa::dl \
        'Config prefix' "${dict[config_prefix]}" \
        'Make prefix' "${dict[make_prefix]}" \
        'Opt prefix' "${dict[opt_prefix]}"
    koopa::add_make_prefix_link
    if koopa::is_linux
    then
        koopa::linux_update_etc_profile_d
        koopa::linux_update_ldconfig
        koopa::linux_configure_system --no-check
    fi
    if [[ -x "${app[brew]}" ]]
    then
        koopa::update_homebrew
    else
        koopa::update_google_cloud_sdk
        koopa::update_perlbrew
        koopa::update_pyenv
        koopa::update_rbenv
    fi
    koopa::update_r_packages
    koopa::update_rust
    koopa::update_rust_packages
    if koopa::is_macos
    then
        koopa::macos_update_microsoft_office || true
    fi
    return 0
}
