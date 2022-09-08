#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'pcre'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='grep' \
        -D '--program-prefix=g' \
        "$@"
}
