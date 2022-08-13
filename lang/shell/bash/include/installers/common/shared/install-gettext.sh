#!/usr/bin/env bash

main() {
    if ! koopa_is_macos
    then
        koopa_activate_opt_prefix 'ncurses' 'libxml2'
    fi
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='gettext' \
        "$@"
}
