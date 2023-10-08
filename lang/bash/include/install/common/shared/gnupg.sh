#!/usr/bin/env bash

main() {
    # """
    # Install GnuPG.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/gnupg.html
    # - https://formulae.brew.sh/formula/gnupg
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=('pkg-config' 'sed')
    deps=(
        'zlib'
        'bzip2'
        'readline'
        'nettle'
        'libtasn1'
        'gnutls'
        'sqlite'
        'libgpg-error'
        'libgcrypt'
        'libassuan'
        'libksba'
        'npth'
        'pinentry'
        'openldap'
        'libiconv'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['libassuan']="$(koopa_app_prefix 'libassuan')"
    dict['libgcrypt']="$(koopa_app_prefix 'libgcrypt')"
    dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
    dict['libksba']="$(koopa_app_prefix 'libksba')"
    dict['npth']="$(koopa_app_prefix 'npth')"
    dict['pinentry']="$(koopa_app_prefix 'pinentry')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    conf_args=(
        # > '--disable-doc'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        '--enable-gnutls'
        "--with-bzip2=${dict['bzip2']}"
        "--with-libassuan-prefix=${dict['libassuan']}"
        "--with-libgcrypt-prefix=${dict['libgcrypt']}"
        "--with-libgpg-error-prefix=${dict['libgpg_error']}"
        "--with-libksba-prefix=${dict['libksba']}"
        "--with-npth-prefix=${dict['npth']}"
        "--with-pinentry-pgm=${dict['pinentry']}"
        "--with-readline=${dict['readline']}"
        "--with-zlib=${dict['zlib']}"
    )
    dict['url']="${dict['gcrypt_url']}/gnupg/gnupg-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
