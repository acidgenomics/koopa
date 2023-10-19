#!/usr/bin/env bash

main() {
    # """
    # Install staden io-lib.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://github.com/jkbonfield/io_lib
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/
    #     staden_io_lib
    # - https://github.com/chapmanb/homebrew-cbl/blob/master/staden_io_lib.rb
    # """
    local -A dict
    local -a conf_args deps
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('curl' 'libdeflate' 'xz' 'zlib' 'zstd')
    koopa_activate_app "${deps[@]}"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['libdeflate']="$(koopa_app_prefix 'libdeflate')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['version2']="$(koopa_kebab_case "${dict['version']}")"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        "--with-libcurl=${dict['curl']}"
        "--with-libdeflate=${dict['libdeflate']}"
        "--with-zlib=${dict['zlib']}"
        "--with-zstd=${dict['zstd']}"
    )
    dict['url']="https://github.com/jkbonfield/io_lib/releases/download/\
io_lib-${dict['version2']}/io_lib-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
