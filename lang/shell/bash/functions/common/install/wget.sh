#!/usr/bin/env bash

koopa::install_wget() { # {{{1
    local conf_args
    koopa::is_macos && koopa::activate_homebrew_pkg_config 'openssl@1.1'
    conf_args=('--with-ssl=openssl')
    koopa::install_gnu_app \
        --name='wget' \
        "${conf_args[@]}" \
        "$@"
}
