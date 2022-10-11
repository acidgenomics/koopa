#!/usr/bin/env bash

main() {
    if ! koopa_is_macos
    then
        koopa_activate_app \
            'gettext' \
            'ncurses' \
            'perl'
    fi
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='texinfo' \
        -D '--disable-dependency-tracking' \
        -D '--disable-install-warnings' \
        "$@"
}
