#!/usr/bin/env bash

# FIXME This is failing to build with ICU 76 on macOS Apple Silicon.
# Undefined symbols for architecture arm64:
#   "_UCNV_FROM_U_CALLBACK_STOP_76", referenced from:
#       _openIcuConverter in libxml2_la-encoding.o
#   "_UCNV_TO_U_CALLBACK_STOP_76", referenced from:
#       _openIcuConverter in libxml2_la-encoding.o
#
# https://gitlab.gnome.org/GNOME/libxml2/-/issues/746
# https://gitlab.gnome.org/GNOME/libxml2/-/commit/b57e022d75425ef8b617a1c3153198ee0a941da8

main() {
    # """
    # Install libxml2.
    # @note Updated 2024-12-30.
    #
    # @seealso
    # - https://github.com/conda-forge/libxml2-feedstock
    # - https://formulae.brew.sh/formula/libxml2
    # - https://ports.macports.org/port/libxml2/details/
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=(
        'make'
        'pkg-config'
    )
    deps=(
        'zlib'
        'icu4c'
        'readline'
        'xz'
        'libiconv'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['autoreconf']="$(koopa_locate_autoreconf)"
    koopa_assert_is_executable "${app['autoreconf']}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['libtool']="$(koopa_app_prefix 'libtool')"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args+=(
        '--disable-dependency-tracking'
        '--enable-static=no'
        "--prefix=${dict['prefix']}"
        '--with-ftp'
        '--with-history'
        "--with-iconv=${dict['libiconv']}"
        "--with-icu=${dict['icu4c']}"
        '--with-legacy'
        "--with-lzma=${dict['xz']}"
        "--with-readline=${dict['readline']}"
        '--with-tls'
        "--with-zlib=${dict['zlib']}"
        '--without-python'
    )
    dict['url']="https://download.gnome.org/sources/libxml2/\
${dict['maj_min_ver']}/libxml2-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cp \
        "${dict['libtool']}/share/libtool/build-aux/config.guess" \
        'config.guess'
    koopa_cp \
        "${dict['libtool']}/share/libtool/build-aux/config.sub" \
        'config.sub'
    # > NOCONFIGURE=1 ./autogen.sh
    # > "${app['autoreconf']}" --force --install --verbose
    koopa_make_build "${conf_args[@]}"
    return 0
}
