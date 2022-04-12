#!/usr/bin/env bash

# FIXME Need to build this with 'ca-certificates' support.
# Otherwise we hit warnings about using '--no-check-certificate' instead.

main() { # {{{1
    # """
    # Install wget.
    # @note Updated 2022-04-11.
    #
    # Use OpenSSL instead of GnuTLS, which is annoying to compile.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local conf_args install_args pkg pkgs
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
        'libidn'
        'openssl'
        'pcre2'
    )
    for pkg in "${pkgs[@]}"
    do
        install_args+=("--activate-opt=${pkg}")
    done
    conf_args=(
        '--disable-debug'
        '--with-ssl=openssl'
        '--without-included-regex'
        '--without-libpsl'
    )
    koopa_install_gnu_app \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
