#!/usr/bin/env bash

# NOTE Currently failing to build on macOS.

koopa::install_wget() { # {{{1
    local conf_args
    if koopa::is_macos
    then
        koopa::activate_homebrew_pkg_config 'openssl@1.1'
    fi
    conf_args=('--with-ssl=openssl')
    koopa::install_gnu_app \
        --name='wget' \
        "${conf_args[@]}" \
        "$@"
}
