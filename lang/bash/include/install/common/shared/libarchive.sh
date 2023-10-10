#!/usr/bin/env bash

main() {
    # """
    # Install libarchive.
    # @note Updated 2023-10-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/libarchive.rb
    # """
    local -A dict
    local -a conf_args deps
    koopa_activate_app --build-only 'pkg-config'
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('expat' 'lz4' 'xz' 'zlib' 'zstd')
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-static'
        "--prefix=${dict['prefix']}"
        '--without-lzma'
        '--without-lzo2'
        '--without-nettle'
        '--without-openssl'
        '--without-xml2'
    )
    dict['url']="https://www.libarchive.org/downloads/\
libarchive-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Fix for breaking change introduced in 3.6.2.
    koopa_find_and_replace_in_file \
        --pattern='Requires.private: @LIBSREQUIRED@' \
        --replacement='' \
        'build/pkgconfig/libarchive.pc.in'
    koopa_make_build "${conf_args[@]}"
    return 0
}
