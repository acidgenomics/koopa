#!/usr/bin/env bash

main() {
    # """
    # Install GnuTLS.
    # @note Updated 2023-05-08.
    #
    # @seealso
    # - https://github.com/conda-forge/gnutls-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gnutls.rb
    # - https://github.com/macports/macports-ports/blob/master/devel/gnutls/
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'gmp' \
        'libtasn1' \
        'libunistring' \
        'nettle'
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-full-test-suite'
        '--disable-guile'
        '--disable-heartbeat-support'
        '--disable-libdane'
        '--disable-maintainer-mode'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-openssl-compatibility'
        "--prefix=${dict['prefix']}"
        '--with-idn'
        '--with-included-unistring'
        '--without-brotli'
        '--without-p11-kit'
        '--without-zlib'
        '--without-zstd'
    )
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['url']="${dict['gcrypt_url']}/gnutls/v${dict['maj_min_ver']}/\
gnutls-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
