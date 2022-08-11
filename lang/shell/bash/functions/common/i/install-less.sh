#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_less() {
    koopa_install_app \
        --activate-opt='ncurses' \
        --activate-opt='pcre2' \
        --installer='gnu-app' \
        --link-in-bin='less' \
        --name='less' \
        "$@"
}
