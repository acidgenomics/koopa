#!/usr/bin/env bash

main() {
    # """
    # Install pinentry.
    # @note Updated 2023-05-08.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     pinentry.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'libiconv' \
        'ncurses' \
        'libgpg-error' \
        'libassuan'
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['libassuan']="$(koopa_app_prefix 'libassuan')"
    dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-inside-emacs'
        '--disable-libsecret'
        '--disable-pinentry-efl'
        '--disable-pinentry-emacs'
        '--disable-pinentry-fltk'
        '--disable-pinentry-gnome3'
        '--disable-pinentry-gtk2'
        '--disable-pinentry-qt'
        '--disable-pinentry-qt4'
        '--disable-pinentry-qt5'
        '--disable-pinentry-tqt'
        '--disable-silent-rules'
        '--enable-pinentry-tty'
        "--prefix=${dict['prefix']}"
        "--with-libassuan-prefix=${dict['libassuan']}"
        "--with-libgpg-error-prefix=${dict['libgpg_error']}"
        "--with-libiconv-prefix=${dict['libiconv']}"
        "--with-ncurses-include-dir=${dict['ncurses']}/include"
    )
    dict['url']="${dict['gcrypt_url']}/pinentry/\
pinentry-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
