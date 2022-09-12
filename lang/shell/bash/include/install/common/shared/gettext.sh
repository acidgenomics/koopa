#!/usr/bin/env bash

main() {
    # Install gettext.
    # @note Updated 2022-09-12.
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
    local dict
    koopa_activate_opt_prefix \
        'bison' \
        'libiconv' \
        'libunistring' \
        'ncurses' \
        'libxml2'
    declare -A dict=(
        ['bison']="$(koopa_app_prefix 'bison')"
        ['libiconv']="$(koopa_app_prefix 'libiconv')"
        ['libunistring']="$(koopa_app_prefix 'libunistring')"
        ['libxml2']="$(koopa_app_prefix 'libxml2')"
        ['ncurses']="$(koopa_app_prefix 'ncurses')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
    )
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='gettext' \
        -D '--disable-csharp' \
        -D '--disable-debug' \
        -D '--disable-dependency-tracking' \
        -D '--disable-java' \
        -D '--disable-silent-rules' \
        -D '--enable-nls' \
        -D '--with-emacs' \
        -D "--with-included-gettext" \
        -D "--with-bison-prefix=${dict['bison']}" \
        -D "--with-libiconv-prefix=${dict['libiconv']}" \
        -D "--with-libncurses-prefix=${dict['ncurses']}" \
        -D "--with-libunistring-prefix=${dict['libunistring']}" \
        -D "--with-libxml2-prefix=${dict['libxml2']}" \
        "$@"
    koopa_assert_is_file \
        "${dict['prefix']}/include/libintl.h" \
        "${dict['prefix']}/lib/libintl.a" \
        "${dict['prefix']}/lib/libintl.la" \
        "${dict['prefix']}/lib/libintl.${dict['shared_ext']}"
    return 0
}
