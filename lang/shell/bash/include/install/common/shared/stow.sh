#!/usr/bin/env bash

main() {
    # """
    # Install script uses 'Test::Output' Perl package.
    # """
    koopa_activate_app 'perl'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='stow'
}
