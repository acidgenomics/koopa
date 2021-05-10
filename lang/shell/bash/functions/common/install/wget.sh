#!/usr/bin/env bash

# NOTE Failing to install on macOS.

koopa::install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-05-10.
    # """
    local conf_args install_args
    install_args=()
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=(
            '--with-ssl=openssl'
        )
    elif koopa::is_macos
    then
        install_args+=(
            '--homebrew-opt=gnutls,libpsl,openssl,pkg-config'
        )
    fi
    koopa::install_gnu_app \
        --name='wget' \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
