#!/usr/bin/env bash

# FIXME Likely need to add 'gettext', 'gnutls', and 'libidn2' support here.

main() { # {{{1
    # """
    # Install wget.
    # @note Updated 2022-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local conf_args dict install_args pkg pkgs
    install_args=(
        '--name=wget'
        '--no-link-in-opt'
        '--no-prefix-check'
        '--quiet'
    )
    pkgs=(
        # > 'gnutls'
        'autoconf'
        'automake'
        'gettext'
        'libidn2'
        'openssl'
        'pcre2'
        'pkg-config'
    )
    for pkg in "${pkgs[@]}"
    do
        install_args+=("--activate-opt=${pkg}")
    done
    conf_args=(
        '--disable-debug'
        '--without-included-regex'
        '--without-libpsl'
        # Use OpenSSL instead of GnuTLS, which is annoying to compile.
        '--with-openssl'
    )
    koopa_install_gnu_app \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
