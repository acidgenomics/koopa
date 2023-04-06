#!/usr/bin/env bash

main() {
    local -a deps
    koopa_activate_app --build-only 'gperf'
    deps=()
    koopa_is_linux && deps+=('attr')
    deps+=('gmp')
    koopa_activate_app "${deps[@]}"
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='coreutils' \
        -D '--program-prefix=g' \
        -D '--with-gmp' \
        -D '--without-selinux' \
        "$@"
}
