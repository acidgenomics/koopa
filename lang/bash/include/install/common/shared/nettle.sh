#!/usr/bin/env bash

main() {
    # """
    # Install nettle.
    # @note Updated 2024-09-18.
    #
    # Need to make sure libhogweed installs.
    # - https://stackoverflow.com/questions/9508851/how-to-compile-gnutls
    # - https://noknow.info/it/os/install_nettle_from_source
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/nettle.html
    # - https://stackoverflow.com/questions/7965990
    # - https://gist.github.com/morgant/1753095
    # """
    local -a conf_args deps install_args
    local conf_arg
    deps+=('gmp' 'm4' 'openssl3')
    koopa_activate_app "${deps[@]}"
    conf_args+=(
        '--disable-dependency-tracking'
        '--disable-static'
        '--enable-mini-gmp'
        '--enable-shared'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    # FIXME We need to set DWARF 4 for GCC 13 when building on CentOS 7.
    if koopa_is_linux
    then
        koopa_append_cppflags '-gdwarf-4'
    fi
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
