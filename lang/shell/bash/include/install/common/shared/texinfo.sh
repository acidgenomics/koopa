#!/usr/bin/env bash

main() {
    koopa_activate_app 'gettext' 'ncurses' 'perl'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='texinfo' \
        -D '--disable-dependency-tracking' \
        -D '--disable-install-warnings' \
        "$@"
}
