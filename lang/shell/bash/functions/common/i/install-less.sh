#!/usr/bin/env bash

koopa_install_less() {
    koopa_install_app \
        --activate-opt='ncurses' \
        --activate-opt='pcre2' \
        --installer='gnu-app' \
        --link-in-bin='bin/less' \
        --name='less' \
        "$@"
}
