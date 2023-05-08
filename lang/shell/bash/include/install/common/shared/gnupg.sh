#!/usr/bin/env bash

main() {
    # """
    # Install GnuPG.
    # @note Updated 2023-05-08.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/gnupg.html
    # - https://gitlab.com/goeb/gnupg-static/-/commit/
    #     42665e459192e3ee1bb6461ae2d4336d8f1f023c
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'bzip2' \
        'readline' \
        'nettle' \
        'libtasn1' \
        'gnutls' \
        'sqlite' \
        'libgpg-error' \
        'libgcrypt' \
        'libassuan' \
        'libksba' \
        'npth' \
        'pinentry'
    app['sed']="$(koopa_locate_sed --allow-system)"
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
    "${app['sed']}" \
        -e '/ks_ldap_free_state/i #if USE_LDAP' \
        -e '/ks_get_state =/a #endif' \
        -i 'dirmngr/server.c'
    koopa_make_build "${conf_args[@]}"
    return 0
}
