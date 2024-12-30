#!/usr/bin/env bash

main() {
    # """
    # Install gettext.
    # @note Updated 2024-12-24.
    #
    # Note that 'libintl.h' is included with glibc.
    #
    # Potentially useful configuration options:
    # * '--with-included-glib'
    # * '--with-included-libxml'
    # * '--with-libtermcap-prefix[=DIR]'
    # * '--with-libtextstyle-prefix[=DIR]'
    # * '--without-libintl-prefix'
    #
    # @seealso
    # - https://github.com/conda-forge/gettext-feedstock
    # - https://formulae.brew.sh/formula/gettext
    # - https://gcc-help.gcc.gnu.narkive.com/CYebbZqg/
    #     cc1-undefined-reference-to-libintl-textdomain
    # """
    local -A dict
    local -a conf_args deps install_args
    local conf_arg
    deps+=(
        'bison'
        'libiconv'
        'libunistring'
        'ncurses'
        'icu4c'
    )
    if ! koopa_is_macos
    then
        deps+=('libxml2')
    fi
    koopa_activate_app "${deps[@]}"
    dict['bison']="$(koopa_app_prefix 'bison')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['libunistring']="$(koopa_app_prefix 'libunistring')"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    conf_args+=(
        # > '--disable-debug'
        # > '--disable-silent-rules'
        # > '--enable-nls'
        # > '--with-included-gettext'
        # > '--with-included-glib'
        # > '--with-included-libcroco'
        # > '--without-cvs'
        # > '--without-git'
        # > '--without-xz'
        '--disable-csharp'
        '--disable-dependency-tracking'
        '--disable-java'
        '--disable-native-java'
        '--disable-openmp'
        '--disable-static'
        '--enable-fast-install'
        "--with-bison-prefix=${dict['bison']}"
        "--with-libiconv-prefix=${dict['libiconv']}"
        "--with-libncurses-prefix=${dict['ncurses']}"
        "--with-libunistring-prefix=${dict['libunistring']}"
        '--without-emacs'
    )
    if koopa_is_linux
    then
        conf_args+=(
            '--with-included-gettext'
            "--with-libxml2-prefix=${dict['libxml2']}"
        )
    fi
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
