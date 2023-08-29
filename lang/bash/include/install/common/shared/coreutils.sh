#!/usr/bin/env bash

main() {
    # """
    # Install GNU coreutils.
    # @note Updated 2023-08-29.
    # """
    local -a conf_args deps install_args
    local conf_arg
    koopa_activate_app --build-only 'gperf'
    deps=()
    koopa_is_linux && deps+=('attr')
    deps+=('gmp')
    koopa_activate_app "${deps[@]}"
    conf_args=(
        '--program-prefix=g'
        '--with-gmp'
        '--without-selinux'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
