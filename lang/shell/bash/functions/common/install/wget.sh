#!/usr/bin/env bash

# NOTE This is failing to build on macOS.

koopa::install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-05-10.
    # """
    local conf_args
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=('--with-ssl=openssl')
    elif koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix \
            pkg-config \
            gnutls \
            openssl
    fi
    koopa::install_gnu_app \
        --name='wget' \
        "${conf_args[@]}" \
        "$@"
}
