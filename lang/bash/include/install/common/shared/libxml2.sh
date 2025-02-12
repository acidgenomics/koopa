#!/usr/bin/env bash

# NOTE Doesn't build currently with ICU 76 release series.

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
    local -A dict
    local -a build_deps conf_args deps
    build_deps=(
        'make'
        'pkg-config'
    )
    deps=(
        'zlib'
        'icu4c75'
        'readline'
        'xz'
        'libiconv'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['icu4c']="$(koopa_app_prefix 'icu4c75')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
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
    koopa_make_build "${conf_args[@]}"
    return 0
}
