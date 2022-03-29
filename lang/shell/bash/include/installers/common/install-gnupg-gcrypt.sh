#!/usr/bin/env bash

install_gnupg_gcrypt() { # {{{1
    # """
    # Install GnuPG gcrypt library.
    # @note Updated 2022-03-29.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpg]='/usr/bin/gpg'
        [gpg_agent]='/usr/bin/gpg-agent'
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [gcrypt_url]="$(koopa_gcrypt_url)"
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[base_url]="${dict[gcrypt_url]}/${dict[name]}"
    dict[tar_file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[tar_url]="${dict[base_url]}/${dict[tar_file]}"
    koopa_download "${dict[tar_url]}" "${dict[tar_file]}"
    if koopa_is_installed "${app[gpg_agent]}"
    then
        dict[sig_file]="${dict[tar_file]}.sig"
        dict[sig_url]="${dict[base_url]}/${dict[sig_file]}"
        koopa_download "${dict[sig_url]}" "${dict[sig_file]}"
        "${app[gpg]}" --verify "${dict[sig_file]}" || return 1
    fi
    koopa_extract "${dict[tar_file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        # > '--enable-maintainer-mode'
        "--prefix=${dict[prefix]}"
    )
    case "${dict[name]}" in
        'libgcrypt' | \
        'libksba')
            conf_args+=(
                --with-libgpg-error-prefix="${dict[prefix]}"
            )
            ;;
        'gnupg')
            conf_args+=(
                # > '--disable-doc'
                "--with-ksba-prefix=${dict[prefix]}"
                "--with-libassuan-prefix=${dict[prefix]}"
                "--with-libgcrypt-prefix=${dict[prefix]}"
                "--with-libgpg-error-prefix=${dict[prefix]}"
                "--with-libgpg-error-prefix=${dict[prefix]}"
                "--with-libksba-prefix=${dict[prefix]}"
                "--with-npth-prefix=${dict[prefix]}"
            )
            ;;
    esac
    # FIXME Does this help?
    LDFLAGS="-Wl,-rpath,${dict[prefix]}/lib/" \
        ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
