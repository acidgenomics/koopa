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
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='gettext' \
        -D '--disable-csharp' \
        -D '--disable-debug' \
        -D '--disable-dependency-tracking' \
        -D '--disable-java' \
        -D '--disable-silent-rules' \
        -D '--disable-static' \
        -D '--enable-nls' \
        -D '--with-emacs' \
        -D "--with-included-gettext" \
        -D "--with-bison-prefix=${dict['bison']}" \
        -D "--with-libiconv-prefix=${dict['libiconv']}" \
        -D "--with-libncurses-prefix=${dict['ncurses']}" \
        -D "--with-libunistring-prefix=${dict['libunistring']}" \
        -D "--with-libxml2-prefix=${dict['libxml2']}"
    koopa_assert_is_file \
        "${dict['prefix']}/include/libintl.h" \
        "${dict['prefix']}/lib/libintl.${dict['shared_ext']}"
    return 0
}
