#!/usr/bin/env bash

main() {
    local -a conf_args install_args
    local conf_arg
    conf_args=(
        '--disable-static'
        '--enable-freetype-config'
        '--enable-shared=yes'
        '--without-harfbuzz'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
