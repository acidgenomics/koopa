#!/usr/bin/env bash

# FIXME Need to rework this as an internal install command, so we don't hit
# activation issues when installing as a binary package.

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_wget() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local dict
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[ssl]="$(koopa_realpath "${dict[opt_prefix]}/openssl3")"
    koopa_install_app \
        --activate-build-opt='autoconf' \
        --activate-build-opt='automake' \
        --activate-opt='gettext' \
        --activate-opt='libidn' \
        --activate-opt='libtasn1' \
        --activate-opt='nettle' \
        --activate-opt='openssl3' \
        --activate-opt='pcre2' \
        --activate-opt='gnutls' \
        --installer='gnu-app' \
        --name='wget' \
        --link-in-bin='wget' \
        --name='wget' \
        -D '--disable-debug' \
        -D '--with-ssl=openssl' \
        -D "--with-libssl-prefix=${dict[ssl]}" \
        -D '--without-included-regex' \
        -D '--without-libpsl' \
        "$@"
}
