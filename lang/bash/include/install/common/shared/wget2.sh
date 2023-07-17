#!/usr/bin/env bash

# FIXME Need to add support for lzlib.
# https://formulae.brew.sh/formula/lzlib

main() {
    # """
    # Install wget2.
    # @note Updated 2023-07-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/wget2
    # - https://gitlab.com/gnuwget/wget2
    # """
    local -a build_deps conf_args deps
    local -A dict
    build_deps=(
        'sed'
        'texinfo'
    )
    deps=(
        'gettext'
        'libidn'
        'libtasn1'
        'nettle'
        'pcre2'
        'gnutls'
        #
        # "brotli"
        # "gettext"
        # "gnutls"
        # "gpgme"
        # "libassuan"
        # "libgpg-error"
        # "libidn2"
        # "libmicrohttpd"
        # "libnghttp2"
        # "libpsl"
        # "libtasn1"
        # "lzlib"
        # "nettle"
        # "p11-kit"
        # "pcre2"
        # "xz"
        # "zstd"
        #
        # "bzip2"
        # "icu4c"
        # "zlib"
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    # > dict['lzlib']="$(koopa_app_prefix 'lzlib')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://ftp.gnu.org/gnu/wget/wget2-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # > export LZIP_CFLAGS="-I${dict['lzlib']}/include"
    # > export LZIP_LIBS="-L${dict['lzlib']}/lib -llz"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-bzip2'
        "--with-libintl-prefix=${dict['gettext']}"
        '--with-lzma'
    )
    koopa_make_build "${conf_args[@]}"
    return 0
}
