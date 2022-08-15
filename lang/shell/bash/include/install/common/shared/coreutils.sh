#!/usr/bin/env bash

main() {
    local deps
    koopa_activate_build_opt_prefix 'gperf'
    deps=()
    koopa_is_linux && deps+=('attr')
    deps+=('gmp')
    koopa_activate_opt_prefix "${deps[@]}"
    koopa_install_app_internal \
        --installer='gnu-app' \
        -D '--with-gmp' \
        -D '--without-selinux' \
        "$@"
}
