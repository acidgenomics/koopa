#!/usr/bin/env bash

koopa::install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-05-10.
    # """
    local conf_args gcc_version install_args
    install_args=()
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=(
            '--with-ssl=openssl'
        )
    elif koopa::is_macos
    then
        gcc_version="$(koopa::variable 'gcc')"
        gcc_version="$(koopa::major_version "$gcc_version")"
        # clang currently fails to build this, so use GCC instead.
        install_args+=(
            "--homebrew-opt=gcc@${gcc_version},gnutls,libpsl,openssl,pkg-config"
        )
        conf_args+=(
            "CC=gcc-${gcc_version}"
        )
    fi
    koopa::install_gnu_app \
        --name='wget' \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
