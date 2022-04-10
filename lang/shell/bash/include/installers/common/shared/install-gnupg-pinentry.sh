#!/usr/bin/env bash

# FIXME This also requires 'fltk' library.

main() { # {{{1
    # """
    # Install GnuPG pinentry library.
    # @note Updated 2022-04-10.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'gnupg' 'ncurses'
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
    conf_args=("--prefix=${dict[prefix]}")
    if koopa_is_opensuse
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
    LDFLAGS="-Wl,-rpath,${dict[prefix]}/lib/" \
        ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
