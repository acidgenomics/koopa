#!/usr/bin/env bash

main() {
    # """
    # Install libtiff.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libtiff.rb
    # - https://gitlab.com/libtiff/libtiff/-/commit/
    #     b25618f6fcaf5b39f0a5b6be3ab2fb288cf7a75b
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libtiff.html
    # - https://github.com/opentoonz/opentoonz/issues/1566
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'libjpeg-turbo' 'zstd'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-lzma'
        '--disable-static'
        '--disable-webp'
        '--enable-shared=yes'
        "--prefix=${dict['prefix']}"
        '--without-x'
    )
    dict['url']="https://download.osgeo.org/libtiff/\
tiff-${dict['version']}.tar.xz"
# >     dict['url']="https://fossies.org/linux/misc/tiff-${dict['version']}.tar.gz"
# >     dict['url']="https://gitlab.com/libtiff/libtiff/-/archive/\
# > v${dict['version']}/libtiff-v${dict['version']}.tar.gz"
# >     dict['url']="https://github.com/libsdl-org/libtiff/archive/refs/tags/\
# > v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
