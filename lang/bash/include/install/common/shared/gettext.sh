#!/usr/bin/env bash

main() {
    # Install gettext.
    # @note Updated 2023-08-30.
    #
    # Note that 'libintl.h' is included with glibc.
    #
    # Potentially useful configuration options:
    # * '--with-included-glib'?
    # * '--with-included-libxml'
    # * '--with-libtermcap-prefix[=DIR]'
    # * '--with-libtextstyle-prefix[=DIR]'
    # * '--without-libintl-prefix'
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/gettext.rb
    # - https://gcc-help.gcc.gnu.narkive.com/CYebbZqg/
    #     cc1-undefined-reference-to-libintl-textdomain
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app \
        'bison' \
        'libiconv' \
        'libunistring' \
        'ncurses' \
        'libxml2'
    dict['bison']="$(koopa_app_prefix 'bison')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['libunistring']="$(koopa_app_prefix 'libunistring')"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"

    conf_args=(
        '--disable-csharp'
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-java'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-nls'
        '--with-emacs'
        '--with-included-gettext'
        "--with-bison-prefix=${dict['bison']}"
        "--with-libiconv-prefix=${dict['libiconv']}"
        "--with-libncurses-prefix=${dict['ncurses']}"
        "--with-libunistring-prefix=${dict['libunistring']}"
        "--with-libxml2-prefix=${dict['libxml2']}"
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    koopa_assert_is_file \
        "${dict['prefix']}/include/libintl.h" \
        "${dict['prefix']}/lib/libintl.${dict['shared_ext']}"
    return 0
}
