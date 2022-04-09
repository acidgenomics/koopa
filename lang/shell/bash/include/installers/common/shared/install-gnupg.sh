#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install GnuPG.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://gnupg.org/download/index.html
    # - https://gnupg.org/signature_key.html
    # - https://gnupg.org/download/integrity_check.html
    # - gpgrt_set_confdir issue during build:
    #   https://zenn.dev/zunda/scraps/70c2bfb4494510
    # """
    local app dict gpg_keys install_args
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpg]='/usr/bin/gpg'
        [gpg_agent]='/usr/bin/gpg-agent'
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[version]}" in
        '2.3.4')
            # 2022-03-29.
            dict[libgpg_error_version]='1.44'     # 2022-01-27
            dict[libgcrypt_version]='1.10.1'      # 2022-03-28
            dict[libksba_version]='1.6.0'         # 2021-06-10
            dict[libassuan_version]='2.5.5'       # 2021-03-22
            dict[npth_version]='1.6'              # 2018-07-16
            dict[pinentry_version]='1.2.0'        # 2021-08-25
            ;;
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
            koopa_stop "Unsupported version: '${dict[version]}'."
            ;;
    esac
    if koopa_is_installed "${app[gpg_agent]}"
    then
        # Can use the last 4 elements per key in the '--rev-keys' call.
        gpg_keys=(
            # Expired legacy keys:
            # > '031EC2536E580D8EA286A9F22071B08A33BD3F06' # expired
            # > 'D8692123C4065DEA5E0F3AB5249B39D24F25E3B6' # expired
            # Extra key needed for pinentry 1.1.1.
            # > '80CC1B8D04C262DDFEE1980C6F7F0F91D138FC7B'
            # Current keys:
            '5B80C5754298F0CB55D8ED6ABCEF7E294B092E28' # 2027-03-15
            '6DAA6E64A76D2840571B4902528897B826403ADA' # 2030-06-30
            'AC8E115BF73E2D8D47FA9908E98E9B2D19C6C8BD' # 2027-04-04
        )
        "${app[gpg]}" \
            --keyserver 'hkp://keyserver.ubuntu.com:80' \
            --recv-keys "${gpg_keys[@]}"
        # List keys with:
        # > "${app[gpg]}" --list-keys
    fi
    install_args=(
        '--installer=gnupg-gcrypt'
        '--no-prefix-check'
        "--prefix=${dict[prefix]}"
        '--quiet'
    )
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libgpg-error' \
        --version="${dict[libgpg_error_version]}" \
        "${install_args[@]}"
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libgcrypt' \
        --version="${dict[libgcrypt_version]}" \
        "${install_args[@]}"
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libassuan' \
        --version="${dict[libassuan_version]}" \
        "${install_args[@]}"
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libksba' \
        --version="${dict[libksba_version]}" \
        "${install_args[@]}"
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='npth' \
        --version="${dict[npth_version]}" \
        "${install_args[@]}"
    koopa_install_app \
        --installer='gnupg-pinentry' \
        --name='pinentry' \
        --version="${dict[pinentry_version]}" \
        "${install_args[@]}"
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='gnupg' \
        --version="${dict[version]}" \
        "${install_args[@]}"
    return 0
}
