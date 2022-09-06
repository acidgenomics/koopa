#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'ncurses' 'pcre2'
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='less' \
        "$@"
}
