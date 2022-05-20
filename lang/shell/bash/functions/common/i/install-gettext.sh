#!/usr/bin/env bash

koopa_install_gettext() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--name=gettext'
    )
    if ! koopa_is_macos
    then
        install_args+=(
            '--activate-opt=ncurses'
            '--activate-opt=libxml2'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
