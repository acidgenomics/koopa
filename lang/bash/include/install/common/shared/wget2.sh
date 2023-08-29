#!/usr/bin/env bash

# NOTE Consider adding support: gpgme, hsts, idn, lzip, ntlm, opie, psl

main() {
    # """
    # Install wget2.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/wget2
    # - https://gitlab.com/gnuwget/wget2
    # """
    local -A dict
    local -a build_deps conf_args deps install_args
    local conf_arg
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
    conf_args=(
        '--with-bzip2'
        "--with-libintl-prefix=${dict['gettext']}"
        "--with-libssl-prefix=${dict['ssl']}"
        '--with-lzma'
        '--with-ssl=openssl'
        '--without-libpsl'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app --parent-name='wget' "${install_args[@]}"
    return 0
}
