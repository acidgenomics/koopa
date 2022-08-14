#!/usr/bin/env bash

main() {
    if ! koopa_is_macos
    then
        koopa_activate_opt_prefix \
            'gettext' \
            'ncurses' \
            'perl'
    fi
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='texinfo' \
        -D '--disable-dependency-tracking' \
        -D '--disable-install-warnings' \
        "$@"
}
