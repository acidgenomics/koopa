#!/usr/bin/env bash

main() {
    # """
    # Install libgeotiff.
    # @note Updated 2024-12-30.
    #
    # @seealso
    # - https://github.com/OSGeo/libgeotiff
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libgeotiff.rb
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=('libtool' 'pkg-config')
    deps=(
        'zlib'
        'zstd'
        'openssl'
        'libssh2'
        'curl'
        'libjpeg-turbo'
        'libtiff'
        'sqlite'
        'proj'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
        '--with-jpeg'
    )
    dict['url']="https://github.com/OSGeo/libgeotiff/releases/download/\
${dict['version']}/libgeotiff-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
