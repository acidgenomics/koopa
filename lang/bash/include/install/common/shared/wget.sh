#!/usr/bin/env bash

main() {
    # """
    # Install wget.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/wget.rb
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app --build-only \
        'autoconf' \
        'automake'
    koopa_activate_app \
        'gettext' \
        'libidn' \
        'libtasn1' \
        'nettle' \
        'openssl' \
        'pcre2' \
        'gnutls'
    dict['ssl']="$(koopa_app_prefix 'openssl')"
    # OpenSSL >= 4.0 removed 'SSLv3_client_method' without defining
    # 'OPENSSL_NO_SSL3_METHOD', which wget checks with '#ifndef'.
    koopa_append_cppflags '-DOPENSSL_NO_SSL3_METHOD'
    conf_args=(
        '--disable-debug'
        "--with-libssl-prefix=${dict['ssl']}"
        '--with-ssl=openssl'
        '--without-included-regex'
        '--without-libpsl'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
