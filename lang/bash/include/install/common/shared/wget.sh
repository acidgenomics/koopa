#!/usr/bin/env bash

main() {
    # """
    # Install wget.
    # @note Updated 2023-03-29.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local -A dict
    koopa_activate_app --build-only \
        'autoconf' \
        'automake'
    koopa_activate_app \
        'gettext' \
        'libidn' \
        'libtasn1' \
        'nettle' \
        'openssl3' \
        'pcre2' \
        'gnutls'
    dict['ssl']="$(koopa_app_prefix 'openssl3')"
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='wget' \
        -D '--disable-debug' \
        -D "--with-libssl-prefix=${dict['ssl']}" \
        -D '--with-ssl=openssl' \
        -D '--without-included-regex' \
        -D '--without-libpsl'
}
