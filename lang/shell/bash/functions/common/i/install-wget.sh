#!/usr/bin/env bash

koopa_install_wget() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local dict
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[ssl]="$(koopa_realpath "${dict[opt_prefix]}/openssl")"
    koopa_install_app \
        --activate-build-opt='autoconf' \
        --activate-build-opt='automake' \
        --activate-opt='gettext' \
        --activate-opt='libidn' \
        --activate-opt='libtasn1' \
        --activate-opt='nettle' \
        --activate-opt='openssl' \
        --activate-opt='pcre2' \
        --activate-opt='gnutls' \
        --installer='gnu-app' \
        --name='wget' \
        --link-in-bin='bin/wget' \
        --name='wget' \
        -D '--disable-debug' \
        -D "--with-ssl=${dict[ssl]}" \
        -D '--without-included-regex' \
        -D '--without-libpsl' \
        "$@"
}
