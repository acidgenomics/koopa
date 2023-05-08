#!/usr/bin/env bash

# FIXME Consider including liblzma from xz
# --with-lzma[=DIR]       use liblzma in DIR

main() {
    # """
    # Install libxml2.
    # @note Updated 2023-04-10.
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
    koopa_make_build "${conf_args[@]}"
    return 0
}
