#!/usr/bin/env bash

# NOTE Consider building GnuPG with gnutls and sqlite3.

main() {
    # """
    # Install GnuPG gcrypt library.
    # @note Updated 2022-08-10.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'autoconf' 'automake' 'pkg-config'
    declare -A app=(
        [gpg]='/usr/bin/gpg'
        [gpg_agent]='/usr/bin/gpg-agent'
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [check_key]=1
        [compress_ext]='bz2'
        [gcrypt_url]="$(koopa_gcrypt_url)"
        [import_gpg_keys]="${INSTALL_IMPORT_GPG_KEYS:-0}"
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        # > '--enable-maintainer-mode'
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
    )
    case "${dict['name']}" in
        'libassuan' | \
        'libgcrypt' | \
        'libksba')
            koopa_activate_opt_prefix 'libgpg-error'
            dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
            conf_args+=(
                "--with-libgpg-error-prefix=${dict['libgpg_error']}"
            )
            ;;
        'gnutls')
            koopa_activate_opt_prefix \
                'gmp' \
                'libtasn1' \
                'libunistring' \
                'nettle'
            conf_args+=('--without-p11-kit')
            ;;
        'pinentry')
            koopa_activate_opt_prefix \
                'fltk' \
                'ncurses' \
                'libgpg-error' \
                'libassuan' \
            ;;
        'gnupg')
            koopa_activate_opt_prefix \
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
                koopa_activate_opt_prefix 'pinentry'
                dict['pinentry']="$(koopa_app_prefix 'pinentry')"
                # FIXME Do we need to point to the pinentry binary here?
                conf_args+=("--with-pinentry-pgm=${dict['pinentry']}")
            fi
            ;;
    esac
    dict['base_url']="${dict['gcrypt_url']}/${dict['name']}"
    case "${dict['name']}" in
        'libgpg-error')
            dict['import_gpg_keys']=1
            ;;
        'dirmngr' | \
        'npth')
            # nPth uses expired 'D8692123C4065DEA5E0F3AB5249B39D24F25E3B6' key.
            # dirmngr is from 2013 and also has an expired key.
            dict['check_key']=0
            ;;
        'gnutls')
            dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
            dict['base_url']="${dict['base_url']}/v${dict['maj_min_ver']}"
            dict['compress_ext']='xz'
            ;;
    esac
    dict['tar_file']="${dict['name']}-${dict['version']}.tar.${dict['compress_ext']}"
    dict['tar_url']="${dict['base_url']}/${dict['tar_file']}"
    koopa_download "${dict['tar_url']}" "${dict['tar_file']}"
    if [[ "${dict['check_key']}" -eq 1 ]] && \
        koopa_is_installed "${app['gpg_agent']}"
    then
        if [[ "${dict['import_gpg_keys']}" -eq 1 ]]
        then
            # Can use the last 4 elements per key in the '--rev-keys' call.
            gpg_keys=(
                # Expired legacy keys:
                # > '031EC2536E580D8EA286A9F22071B08A33BD3F06' # expired
                # > 'D8692123C4065DEA5E0F3AB5249B39D24F25E3B6' # expired
                # Extra key needed for pinentry 1.1.1.
                # > '80CC1B8D04C262DDFEE1980C6F7F0F91D138FC7B'
                # Current GnuPG keys:
                '02F38DFF731FF97CB039A1DA549E695E905BA208'
                '5B80C5754298F0CB55D8ED6ABCEF7E294B092E28' # 2027-03-15
                '6DAA6E64A76D2840571B4902528897B826403ADA' # 2030-06-30
                'AC8E115BF73E2D8D47FA9908E98E9B2D19C6C8BD' # 2027-04-04
                # Current GnuTLS keys:
                '5D46CB0F763405A7053556F47A75A648B3F9220C'
                '462225C3B46F34879FC8496CD605848ED7E69871'
            )
            "${app['gpg']}" \
                --keyserver 'hkp://keyserver.ubuntu.com:80' \
                --recv-keys "${gpg_keys[@]}"
            # List keys with:
            # > "${app['gpg']}" --list-keys
        fi
        dict['sig_file']="${dict['tar_file']}.sig"
        dict['sig_url']="${dict['base_url']}/${dict['sig_file']}"
        koopa_download "${dict['sig_url']}" "${dict['sig_file']}"
        "${app['gpg']}" --verify "${dict['sig_file']}" || return 1
    fi
    koopa_extract "${dict['tar_file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
