#!/usr/bin/env bash

koopa::configure_dotfiles() { # {{{1
    # """
    # Configure dotfiles.
    # @note Updated 2021-11-24.
    # """
    local app dict
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="$(koopa::dotfiles_prefix)"
    )
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    koopa::add_koopa_config_link "${dict[prefix]}" "${dict[name]}"
    "${app[bash]}" "${dict[script]}"
    return 0
}

koopa::configure_go() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        --which-app="$(koopa::locate_go)" \
        "$@"
}

koopa::configure_julia() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        --which-app="$(koopa::locate_julia)" \
        "$@"
}

koopa::configure_nim() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        --which-app="$(koopa::locate_nim)" \
        "$@"
}

koopa::configure_node() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        --which-app="$(koopa::locate_node)" \
        "$@"
}

koopa::configure_ruby() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        --which-app="$(koopa::locate_ruby)" \
        "$@"
    koopa::rm "${HOME}/.gem"
    return 0
}

koopa::configure_rust() { # {{{1
    # """
    # Configure Rust.
    # @note Updated 2021-09-17.
    # """
    koopa::configure_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        --version='rolling' \
        "$@"
}
