#!/usr/bin/env bash

install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-11-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local conf_args dict install_args pkg pkgs
    install_args=(
        '--name=wget'
        '--no-prefix-check'
        '--quiet'
    )
    conf_args=()
    if koopa_is_linux
    then
        conf_args+=(
            '--with-ssl=openssl'
        )
    elif koopa_is_macos
    then
        declare -A dict
        dict[gcc_version]="$(koopa_variable 'gcc')"
        dict[gcc_maj_ver]="$(koopa_major_version "${dict[gcc_version]}")"
        pkgs=(
            "gcc@${dict[gcc_maj_ver]}"
            'autoconf'
            'automake'
            'gettext'
            'gnutls'
            'libidn2'
            'openssl'
            'pkg-config'
        )
        for pkg in "${pkgs[@]}"
        do
            install_args+=("--homebrew-opt=${pkg}")
        done
        conf_args+=(
            "CC=gcc-${dict[gcc_maj_ver]}"
            '--disable-debug'
            '--disable-pcre'
            '--without-included-regex'
            '--without-libpsl'
        )
    fi
    koopa_install_gnu_app \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
