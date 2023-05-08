#!/usr/bin/env bash

# FIXME Need to fix iconv library paths
# https://github.com/GNOME/libxml2/commit/3463063001f36c16e5f6ce9ad33cd12a376fc874

# FIXME Hitting this autoreconf issue:
# autoreconf: running: /opt/koopa/app/autoconf/2.71/bin/autoconf --force
# configure.ac:1075: error: possibly undefined macro: m4_ifdef
#       If this token and others are legitimate, please use m4_pattern_allow.
#       See the Autoconf documentation.
# autoreconf: error: /opt/koopa/app/autoconf/2.71/bin/autoconf failed with exit status: 1

main() {
    # """
    # Install libxml2.
    # @note Updated 2023-05-08.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=('make' 'pkg-config')
    deps=(
        'zlib'
        'icu4c'
        'readline'
        'libiconv'
        'xz'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--enable-static=no'
        "--prefix=${dict['prefix']}"
        '--with-ftp'
        '--with-history'
        "--with-iconv=${dict['libiconv']}"
        '--with-icu'
        '--with-legacy'
        "--with-lzma=${dict['xz']}"
        "--with-readline=${dict['readline']}"
        "--with-zlib=${dict['zlib']}"
        '--without-python'
    )
    dict['url']="https://download.gnome.org/sources/libxml2/\
${dict['maj_min_ver']}/libxml2-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_activate_app --build-only autoconf automake libtool m4
    dict['automake']="$(koopa_app_prefix 'automake')"
    aclocal "-I${dict['automake']}/share/aclocal-1.16"
    aclocal --print
    # FIXME This needs to include:
    # /opt/koopa/app/automake/1.16.5/share/aclocal
    # /opt/koopa/app/automake/1.16.5/share/aclocal
    autoreconf \
        --include="${dict['automake']}/share/aclocal-1.16" \
        --force \
        --install \
        --verbose
    # FIXME Need to patch Makefile.
    # FIXME Need to patch configure.
    koopa_stop 'FIXME'

    # Makefile.in
    # from:
    # 'xmllint_CFLAGS = $(AM_CFLAGS) $(RDL_CFLAGS)'
    # to:
    # 'xmllint_CFLAGS = $(AM_CFLAGS) $(RDL_CFLAGS) $(ICONV_CFLAGS)'

    # configure
    # from:
    # LIBS="$LIBS -L$ICONV_DIR/libs"
    # to:
    # LIBS="$LIBS -L$ICONV_DIR/lib"
    #
    # from:
    # AC_SUBST(WITH_ICONV)
    # to:
    # AC_SUBST(WITH_ICONV)
    # AC_SUBST(ICONV_CFLAGS)
    #
    # from:
    # ICU_LIBS="-L$ICU_DIR/libs $ICU_LIBS"
    # to:
    # ICU_LIBS="-L$ICU_DIR/lib $ICU_LIBS"

    koopa_make_build "${conf_args[@]}"
    return 0
}
