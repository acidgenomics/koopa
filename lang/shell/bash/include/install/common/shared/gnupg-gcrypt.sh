#!/usr/bin/env bash

main() {
    # """
    # Install GnuPG gcrypt library.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'make' \
        'pkg-config'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['compress_ext']='bz2'
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        # > '--enable-maintainer-mode'
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    case "${dict['name']}" in
        'libgpg-error')
            # NOTE: gpg-error-config is deprecated upstream.
            # https://dev.gnupg.org/T5683
            conf_args+=('--enable-install-gpg-error-config')
            ;;
        'libassuan' | \
        'libgcrypt' | \
        'libksba')
            koopa_activate_app 'libgpg-error'
            dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
            conf_args+=(
                "--with-libgpg-error-prefix=${dict['libgpg_error']}"
            )
            ;;
        'gnutls')
            koopa_activate_app \
                'gmp' \
                'libtasn1' \
                'libunistring' \
                'nettle'
            conf_args+=('--without-p11-kit')
            ;;
        'pinentry')
            koopa_activate_app \
                'fltk' \
                'ncurses' \
                'libgpg-error' \
                'libassuan'
            ;;
        'gnupg')
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
                'npth'
            dict['bzip2']="$(koopa_app_prefix 'bzip2')"
            dict['libassuan']="$(koopa_app_prefix 'libassuan')"
            dict['libgcrypt']="$(koopa_app_prefix 'libgcrypt')"
            dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
            dict['libksba']="$(koopa_app_prefix 'libksba')"
            dict['npth']="$(koopa_app_prefix 'npth')"
            dict['readline']="$(koopa_app_prefix 'readline')"
            dict['zlib']="$(koopa_app_prefix 'zlib')"
            conf_args+=(
                # > '--disable-doc'
                '--enable-gnutls'
                "--with-bzip2=${dict['bzip2']}"
                "--with-libassuan-prefix=${dict['libassuan']}"
                "--with-libgcrypt-prefix=${dict['libgcrypt']}"
                "--with-libgpg-error-prefix=${dict['libgpg_error']}"
                "--with-libksba-prefix=${dict['libksba']}"
                "--with-npth-prefix=${dict['npth']}"
                "--with-readline=${dict['readline']}"
                "--with-zlib=${dict['zlib']}"
            )
            if koopa_is_linux
            then
                koopa_activate_app 'pinentry'
                dict['pinentry']="$(koopa_app_prefix 'pinentry')"
                # NOTE Do we need to point to the pinentry binary here?
                conf_args+=("--with-pinentry-pgm=${dict['pinentry']}")
            fi
            ;;
    esac
    dict['base_url']="${dict['gcrypt_url']}/${dict['name']}"
    case "${dict['name']}" in
        'gnutls')
            dict['compress_ext']='xz'
            dict['maj_min_ver']="$( \
                koopa_major_minor_version "${dict['version']}" \
            )"
            dict['base_url']="${dict['base_url']}/v${dict['maj_min_ver']}"
            ;;
    esac
    dict['tar_file']="${dict['name']}-${dict['version']}.\
tar.${dict['compress_ext']}"
    dict['tar_url']="${dict['base_url']}/${dict['tar_file']}"
    koopa_download "${dict['tar_url']}" "${dict['tar_file']}"
    koopa_extract "${dict['tar_file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    case "${dict['name']}" in
        'gnupg')
            # May only need to apply this to 2.3.8.
            gnupg_patch_dirmngr
            ;;
    esac
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

gnupg_patch_dirmngr() {
    # """
    # Fix an issue causing build failure if OpenLDAP is not installed.
    # @note Updated 2022-11-15.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/gnupg.html
    # - https://gitlab.com/goeb/gnupg-static/-/commit/
    #     42665e459192e3ee1bb6461ae2d4336d8f1f023c
    # """
    local -A app
    app['sed']="$(koopa_locate_sed)"
    [[ -x "${app['sed']}" ]] || exit 1
    "${app['sed']}" \
        -e '/ks_ldap_free_state/i #if USE_LDAP' \
        -e '/ks_get_state =/a #endif' \
        -i 'dirmngr/server.c'
    return 0
}
