#!/usr/bin/env bash

koopa:::install_gnupg() { # {{{1
    # """
    # Install GnuPG.
    # @note Updated 2021-11-30.
    #
    # @seealso
    # - https://gnupg.org/download/index.html
    # - https://gnupg.org/signature_key.html
    # - https://gnupg.org/download/integrity_check.html
    # """
    local app dict gpg_keys install_args opt opt_arr
    declare -A app=(
        [gpg]='/usr/bin/gpg'
        [gpg_agent]='/usr/bin/gpg-agent'
    )
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[version]}" in
        '2.3.3')
            # 2021-10-12.
            dict[libgpg_error_version]='1.43'     # 2021-11-03
            dict[libgcrypt_version]='1.9.4'       # 2021-08-22
            dict[libksba_version]='1.6.0'         # 2021-06-10
            dict[libassuan_version]='2.5.5'       # 2021-03-22
            dict[npth_version]='1.6'              # 2018-07-16
            dict[pinentry_version]='1.2.0'        # 2021-08-25
            ;;
        '2.3.2')
            # 2021-08-24.
            dict[libgpg_error_version]='1.42'     # 2021-03-22
            dict[libgcrypt_version]='1.9.4'       # 2021-08-22
            dict[libksba_version]='1.6.0'         # 2021-06-10
            dict[libassuan_version]='2.5.5'       # 2021-03-22
            dict[npth_version]='1.6'              # 2018-07-16
            dict[pinentry_version]='1.2.0'        # 2021-08-25
            ;;
        '2.3.1')
            # 2021-04-20.
            dict[libgpg_error_version]='1.42'     # 2021-03-22
            dict[libgcrypt_version]='1.9.3'       # 2021-04-19
            dict[libksba_version]='1.5.1'         # 2021-04-06
            dict[libassuan_version]='2.5.5'       # 2021-03-22
            dict[npth_version]='1.6'              # 2018-07-16
            dict[pinentry_version]='1.1.1'        # 2021-01-22
            ;;
        '2.2.33')
            # 2021-11-30 (LTS).
            dict[libgpg_error_version]='1.43'
            dict[libgcrypt_version]='1.8.8'
            dict[libksba_version]='1.6.0'
            dict[libassuan_version]='2.5.5'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.2.0'
            ;;
        '2.2.26' | \
        '2.2.27')
            dict[libgpg_error_version]='1.41'
            dict[libgcrypt_version]='1.8.7'
            dict[libksba_version]='1.5.0'
            dict[libassuan_version]='2.5.4'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.1.0'
            ;;
        '2.2.25' | \
        '2.2.24')
            # 2.2.25: 2020-11-24.
            # 2.2.24: 2020-11-17.
            dict[libgpg_error_version]='1.39'
            dict[libgcrypt_version]='1.8.7'
            dict[libksba_version]='1.5.0'
            dict[libassuan_version]='2.5.4'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.1.0'
            ;;
        '2.2.23')
            # 2020-09-03.
            dict[libgpg_error_version]='1.39'
            dict[libgcrypt_version]='1.8.7'
            dict[libksba_version]='1.4.0'
            dict[libassuan_version]='2.5.4'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.1.0'
            ;;
        '2.2.21')
            # 2020-07-09.
            dict[libgpg_error_version]='1.38'
            dict[libgcrypt_version]='1.8.6'
            dict[libksba_version]='1.4.0'
            dict[libassuan_version]='2.5.3'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.1.0'
            ;;
        '2.2.20')
            # 2020-03-20.
            dict[libgpg_error_version]='1.38'
            dict[libgcrypt_version]='1.8.5'
            dict[libksba_version]='1.4.0'
            dict[libassuan_version]='2.5.3'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.1.0'
            ;;
        '2.2.19')
            # 2019-12-07.
            dict[libgpg_error_version]='1.37'
            dict[libgcrypt_version]='1.8.5'
            dict[libksba_version]='1.3.5'
            dict[libassuan_version]='2.5.3'
            dict[npth_version]='1.6'
            dict[pinentry_version]='1.1.0'
            ;;
        *)
            koopa::stop "Unsupported version: '${dict[version]}'."
            ;;
    esac
    if koopa::is_installed "${app[gpg_agent]}"
    then
        # Current releases are signed by one or more of these keys:
        #
        # pub   rsa2048 2011-01-12 [expires: 2021-12-31]
        #       D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6
        # uid   Werner Koch (dist sig)
        #
        # pub   rsa2048 2014-10-29 [expires: 2020-10-30]
        #       031E C253 6E58 0D8E A286  A9F2 2071 B08A 33BD 3F06
        # uid   NIIBE Yutaka (GnuPG Release Key) <gniibe 'at' fsij.org>
        #
        # pub   rsa3072 2017-03-17 [expires: 2027-03-15]
        #       5B80 C575 4298 F0CB 55D8  ED6A BCEF 7E29 4B09 2E28
        # uid   Andre Heinecke (Release Signing Key)
        #
        # pub   ed25519 2020-08-24 [expires: 2030-06-30]
        #       6DAA 6E64 A76D 2840 571B  4902 5288 97B8 2640 3ADA
        # uid   Werner Koch (dist signing 2020)
        #
        # Can use the last 4 elements per key in the '--rev-keys' call.
        gpg_keys=(
            'D8692123C4065DEA5E0F3AB5249B39D24F25E3B6'
            '031EC2536E580D8EA286A9F22071B08A33BD3F06'
            '5B80C5754298F0CB55D8ED6ABCEF7E294B092E28'
            '6DAA6E64A76D2840571B4902528897B826403ADA'
            # Extra key needed for pinentry 1.1.1.
            '80CC1B8D04C262DDFEE1980C6F7F0F91D138FC7B'
        )
        "${app[gpg]}" \
            --keyserver 'hkp://keyserver.ubuntu.com:80' \
            --recv-keys "${gpg_keys[@]}"
        "${app[gpg]}" --list-keys
    fi
    # Install dependencies.
    koopa::install_app \
        --installer='gnupg-gcrypt' \
        --name='libgpg-error' \
        --version="${dict[libgpg_error_version]}" \
        "$@"
    koopa::install_app \
        --installer='gnupg-gcrypt' \
        --name='libgcrypt' \
        --opt='libgpg-error' \
        --version="${dict[libgcrypt_version]}" \
        "$@"
    koopa::install_app \
        --installer='gnupg-gcrypt' \
        --name='libassuan' \
        --opt='libgpg-error' \
        --version="${dict[libassuan_version]}" \
        "$@"
    koopa::install_app \
        --installer='gnupg-gcrypt' \
        --name='libksba' \
        --opt='libgpg-error' \
        --version="${dict[libksba_version]}" \
        "$@"
    koopa::install_app \
        --installer='gnupg-gcrypt' \
        --name='npth' \
        --version="${dict[npth_version]}" \
        "$@"
    if koopa::is_macos
    then
        koopa::alert_note 'Skipping installation of pinentry on macOS.'
    else
        koopa::install_app \
            --installer='gnupg-pinentry' \
            --name='pinentry' \
            --version="${dict[pinentry_version]}" \
            "$@"
    fi
    install_args=(
        "--version=${dict[version]}"
        '--installer=gnupg-gcrypt'
        '--name=gnupg'
        '--no-prefix-check'
    )
    opt_arr=(
        'libgpg-error'
        'libgcrypt'
        'libassuan'
        'libksba'
        'npth'
    )
    if ! koopa::is_macos
    then
        opt_arr+=('pinentry')
    fi
    for opt in "${opt_arr[@]}"
    do
        install_args+=("--opt=${opt}")
    done
    koopa::install_app "${install_args[@]}" "$@"
    return 0
}

koopa:::install_gnupg_gcrypt() { # {{{1
    # """
    # Install GnuPG gcrypt library.
    # @note Updated 2021-11-30.
    # """
    local app dict
    declare -A app=(
        [gpg]='/usr/bin/gpg'
        [gpg_agent]='/usr/bin/gpg-agent'
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [gcrypt_url]="$(koopa::gcrypt_url)"
        [jobs]="$(koopa::cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[base_url]="${dict[gcrypt_url]}/${dict[name]}"
    dict[tar_file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[tar_url]="${dict[base_url]}/${dict[tar_file]}"
    koopa::download "${dict[tar_url]}" "${dict[tar_file]}"
    if koopa::is_installed "${app[gpg_agent]}"
    then
        dict[sig_file]="${dict[tar_file]}.sig"
        dict[sig_url]="${dict[base_url]}/${dict[sig_file]}"
        koopa::download "${dict[sig_url]}" "${dict[sig_file]}"
        "${app[gpg]}" --verify "${dict[sig_file]}" || return 1
    fi
    koopa::extract "${dict[tar_file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

koopa:::install_gnupg_pinentry() { # {{{1
    # """
    # Install GnuPG pinentry library.
    # @note Updated 2021-11-30.
    # """
    local app conf_args dict
    declare -A app=(
        [gpg]='/usr/bin/gpg'
        [gpg_agent]='/usr/bin/gpg-agent'
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [gcrypt_url]="$(koopa::gcrypt_url)"
        [jobs]="$(koopa::cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[base_url]="${dict[gcrypt_url]}/${dict[name]}"
    dict[tar_file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[tar_url]="${dict[base_url]}/${dict[tar_file]}"
    koopa::download "${dict[tar_url]}" "${dict[tar_file]}"
    if koopa::is_installed "${app[gpg_agent]}"
    then
        dict[sig_file]="${dict[tar_file]}.sig"
        dict[sig_url]="${dict[base_url]}/${dict[sig_file]}"
        koopa::download "${dict[sig_url]}" "${dict[sig_file]}"
        "${app[gpg]}" --verify "${dict[sig_file]}" || return 1
    fi
    koopa::extract "${dict[tar_file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    conf_args=("--prefix=${dict[prefix]}")
    if koopa::is_opensuse
    then
        # Build with ncurses is currently failing on openSUSE, due to
        # hard-coded link to '/usr/include/ncursesw' that isn't easy to resolve.
        # Falling back to using 'pinentry-tty' instead in this case.
        conf_args+=(
            '--disable-fallback-curses'
            '--disable-pinentry-curses'
            '--enable-pinentry-tty'
        )
    else
        conf_args+=('--enable-pinentry-curses')
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
