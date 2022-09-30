#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'pcre2'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='grep' \
        -D '--disable-dependency-tracking' \
        -D '--disable-nls' \
        -D '--program-prefix=g' \
        "$@"
}
