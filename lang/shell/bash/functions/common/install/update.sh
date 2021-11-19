#!/usr/bin/env bash

koopa::update_chemacs() { # {{{1
    koopa::update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

koopa::update_julia_packages() { # {{{1
    koopa::install_julia_packages "$@"
}

koopa::update_koopa() { # {{{1
    koopa::update_app \
        --name='koopa' \
        --prefix="$(koopa::koopa_prefix)" \
        --system \
        "$@"
}

koopa::update_nim_packages() { # {{{1
    koopa::install_nim_packages "$@"
}

koopa::update_node_packages() { # {{{1
    koopa::install_node_packages "$@"
}

koopa::update_perl_packages() { # {{{1
    koopa::install_perl_packages "$@"
}

koopa::update_python_packages() { # {{{1
    koopa::update_app \
        --name='python-packages' \
        --name-fancy='Python packages' \
        "$@"
}

koopa::update_rust_packages() { # {{{1
    koopa::update_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa::update_system() { # {{{1
    # """
    # Update system installation.
    # @note Updated 2021-11-18.
    # """
    local dict
    koopa::assert_is_admin
    declare -A dict=(
        [config_prefix]="$(koopa::config_prefix)"
        [make_prefix]="$(koopa::make_prefix)"
        [opt_prefix]="$(koopa::opt_prefix)"
    )
    koopa::update_koopa
    koopa::h1 'Updating system configuration.'
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
    if koopa::is_installed 'brew'
    then
        koopa::update_homebrew
    else
        koopa::update_google_cloud_sdk
        koopa::update_perlbrew
        koopa::update_pyenv
        koopa::update_rbenv
    fi
    koopa::update_python_packages
    koopa::update_r_packages
    koopa::update_rust
    koopa::update_rust_packages
    if koopa::is_macos
    then
        koopa::macos_update_microsoft_office || true
    fi
    koopa::alert_success 'System update was successful.'
    return 0
}

koopa::update_tex_packages() { # {{{1
    koopa::update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
