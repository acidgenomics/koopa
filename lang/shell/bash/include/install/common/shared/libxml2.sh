#!/usr/bin/env bash

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
    deps=('zlib' 'icu4c' 'readline')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
        '--with-history'
        '--with-icu'
        '--without-lzma'
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
