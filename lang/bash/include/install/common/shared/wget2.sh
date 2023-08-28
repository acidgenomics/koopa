#!/usr/bin/env bash

# NOTE Consider adding support: gpgme, hsts, idn, lzip, ntlm, opie, psl

main() {
    # """
    # Install wget2.
    # @note Updated 2023-07-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/wget2
    # - https://gitlab.com/gnuwget/wget2
    # """
    local -a build_deps deps
    local -A dict
    build_deps=('sed' 'texinfo')
    deps=(
        'brotli'
        'bzip2'
        'xz'
        'zlib'
        'zstd'
        'gettext'
        'libidn'
        'libtasn1'
        'nettle'
        'openssl3'
        'pcre2'
        'gnutls'
        'icu4c'
        'libgpg-error'
        'libassuan'
        'nghttp2'
        # Consider adding:
        # > 'gpgme'
        # > 'libmicrohttpd'
        # > 'libpsl'
        # > 'lzlib'
        # > 'p11-kit'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['ssl']="$(koopa_app_prefix 'openssl3')"
    # > dict['lzlib']="$(koopa_app_prefix 'lzlib')"
    # > export LZIP_CFLAGS="-I${dict['lzlib']}/include"
    # > export LZIP_LIBS="-L${dict['lzlib']}/lib -llz"
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='wget2' \
        -D '--with-bzip2' \
        -D "--with-libintl-prefix=${dict['gettext']}" \
        -D "--with-libssl-prefix=${dict['ssl']}" \
        -D '--with-lzma' \
        -D '--with-ssl=openssl' \
        -D '--without-libpsl'
}
