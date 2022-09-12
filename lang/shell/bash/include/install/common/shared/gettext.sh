#!/usr/bin/env bash

# NOTE Consider adding support for bison.

main() {
    # Install gettext.
    # @note Updated 2022-09-12.
    #
    # Note that 'libintl.h' is included with glibc.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/gettext.rb
    # - https://gcc-help.gcc.gnu.narkive.com/CYebbZqg/
    #     cc1-undefined-reference-to-libintl-textdomain
    # """
    local dict
    koopa_activate_opt_prefix 'ncurses' 'libxml2'
    declare -A dict=(
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
        -D "--with-libxml2-prefix=${dict['libxml2']}" \
        -D "--with-ncurses-prefix=${dict['ncurses']}" \
        -D "--with-included-gettext" \
        -D '--with-included-glib' \
        -D '--with-included-libcroco' \
        -D '--with-included-libunistring' \
        -D '--with-included-libxml' \
        -D '--without-cvs' \
        -D '--without-git' \
        -D '--without-xz' \
        "$@"
    koopa_assert_is_file \
        "${dict['prefix']}/include/libintl.h" \
        "${dict['prefix']}/lib/libintl.a" \
        "${dict['prefix']}/lib/libintl.la" \
        "${dict['prefix']}/lib/libintl.${dict['shared_ext']}"
    return 0
}
