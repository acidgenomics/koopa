#!/usr/bin/env bash

main() {
    # """
    # Install GNU coreutils.
    # @note Updated 2024-09-22.
    # """
    local -a conf_args deps install_args
    local conf_arg
    _koopa_activate_app --build-only 'gperf'
    deps=()
    _koopa_is_linux && deps+=('attr')
    deps+=('gmp')
    _koopa_activate_app "${deps[@]}"
    conf_args+=('--program-prefix=g')
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    _koopa_install_gnu_app "${install_args[@]}"
    return 0
}
