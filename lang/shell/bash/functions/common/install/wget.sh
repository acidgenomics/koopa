#!/usr/bin/env bash

koopa::install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-05-10.
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local conf_args gcc_version install_args pkgs pkgs_string
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
        pkgs=(
            'autoconf'
            'automake'
            "gcc@${gcc_version}"
            'gettext'
            'gnutls'
            'libidn2'
            'openssl'
            'pkg-config'
        )
        pkgs_string="$(koopa::paste0 ',' "${pkgs[@]}")"
        install_args+=(
            "--homebrew-opt=${pkgs_string}"
        )
        conf_args+=(
            "CC=gcc-${gcc_version}"
            '--disable-debug'
            '--disable-pcre'
            '--without-included-regex'
            '--without-libpsl'
        )
    fi
    koopa::install_gnu_app \
        --name='wget' \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
