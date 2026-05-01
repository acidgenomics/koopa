#!/usr/bin/env bash

main() {
    # """
    # Install GnuPG.
    # @note Updated 2023-10-17.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/gnupg.html
    # - https://formulae.brew.sh/formula/gnupg
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=('pkg-config' 'sed')
    ! _koopa_is_macos && deps+=('bzip2')
    deps+=(
        'zlib'
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
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    app['sed']="$(_koopa_locate_sed)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gcrypt_url']="$(_koopa_gcrypt_url)"
    dict['libassuan']="$(_koopa_app_prefix 'libassuan')"
    dict['libgcrypt']="$(_koopa_app_prefix 'libgcrypt')"
    dict['libgpg_error']="$(_koopa_app_prefix 'libgpg-error')"
    dict['libksba']="$(_koopa_app_prefix 'libksba')"
    dict['npth']="$(_koopa_app_prefix 'npth')"
    dict['pinentry']="$(_koopa_app_prefix 'pinentry')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(_koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    conf_args+=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        '--enable-gnutls'
        "--with-libassuan-prefix=${dict['libassuan']}"
        "--with-libgcrypt-prefix=${dict['libgcrypt']}"
        "--with-libgpg-error-prefix=${dict['libgpg_error']}"
        "--with-libksba-prefix=${dict['libksba']}"
        "--with-npth-prefix=${dict['npth']}"
        "--with-pinentry-pgm=${dict['pinentry']}"
        "--with-readline=${dict['readline']}"
        "--with-zlib=${dict['zlib']}"
    )
    if ! _koopa_is_macos
    then
        dict['bzip2']="$(_koopa_app_prefix 'bzip2')"
        conf_args+=("--with-bzip2=${dict['bzip2']}")
    fi
    dict['url']="${dict['gcrypt_url']}/gnupg/gnupg-${dict['version']}.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
