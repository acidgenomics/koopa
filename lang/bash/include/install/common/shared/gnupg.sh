#!/usr/bin/env bash

# The installer doesn't honor '--disable-ldap' anymore, which is problematic
# currently on Linux.

# FIXME 2.4.3 fails to build on Linux if LDAP is not installed.

# /usr/bin/ld: server.o: in function `cmd_ad_query':
# server.c:(.text+0x1db4): undefined reference to `ks_ldap_help_variables'
# collect2: error: ld returned 1 exit status
# make[2]: *** [Makefile:937: dirmngr] Error 1
# 
# I saw there was a bug related to this that was fixed upstream, but it still seems to be an issue with the port: https://dev.gnupg.org/T6239

# FIXME Consider requiring openldap here.
# https://github.com/Homebrew/homebrew-core/blob/b124d57c4c711699749c9b1ebb98c21c74588452/Formula/g/gnupg.rb

main() {
    # """
    # Install GnuPG.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # How to disable ldap requirement ('--disable-ldap'):
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/gnupg.html
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/gnupg.html
    # - https://dev.gnupg.org/T6239
    # - https://gitlab.com/goeb/gnupg-static/-/commit/
    #     42665e459192e3ee1bb6461ae2d4336d8f1f023c
    # - https://crux.nu/bugs/index.php?do=details&task_id=1935
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=('pkg-config' 'sed')
    # FIXME Add openldap support here.
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
    # FIXME Here's a patch for that, need to rework.
    # src/dirmngr/server.c:2779: undefined reference to `ks_ldap_help_variables'
    "${app['sed']}" \
        -e '/ks_ldap_free_state/i #if USE_LDAP' \
        -e '/ks_get_state =/a #endif' \
        -i'.bak' \
        'dirmngr/server.c'
    koopa_make_build "${conf_args[@]}"
    return 0
}
