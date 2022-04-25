#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install wget.
    # @note Updated 2022-04-25.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    koopa_install_gnu_app \
        --activate-build-opt='autoconf' \
        --activate-build-opt='automake' \
        --activate-opt='gettext' \
        --activate-opt='libidn' \
        --activate-opt='libtasn1' \
        --activate-opt='nettle' \
        --activate-opt='openssl' \
        --activate-opt='pcre2' \
        --activate-opt='gnutls' \
        --name='wget' \
        --no-link-in-opt \
        --no-prefix-check \
        --quiet \
        -D '--disable-debug' \
        -D '--with-ssl=openssl' \
        -D '--without-included-regex' \
        -D '--without-libpsl' \
        "$@"
}
