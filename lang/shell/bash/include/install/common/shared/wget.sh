#!/usr/bin/env bash

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local dict
    koopa_activate_build_opt_prefix \
        'autoconf' \
        'automake'
    koopa_activate_opt_prefix \
        'gettext' \
        'libidn' \
        'libtasn1' \
        'nettle' \
        'openssl3' \
        'pcre2' \
        'gnutls'
    declare -A dict=(
        [ssl]="$(koopa_app_prefix 'openssl3')"
    )
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='wget' \
        -D '--disable-debug' \
        -D '--with-ssl=openssl' \
        -D "--with-libssl-prefix=${dict[ssl]}" \
        -D '--without-included-regex' \
        -D '--without-libpsl' \
        "$@"
}
