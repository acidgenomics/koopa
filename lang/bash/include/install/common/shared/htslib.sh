#!/usr/bin/env bash

main() {
    # """
    # Install htslib.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/samtools/htslib/
    # """
    local -A dict
    local -a conf_args deps
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('curl' 'libdeflate' 'openssl3' 'xz' 'zlib')
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-gcs'
        '--enable-libcurl'
        '--enable-plugins'
        '--enable-s3'
        "--prefix=${dict['prefix']}"
        '--with-libdeflate'
    )
    dict['url']="https://github.com/samtools/htslib/releases/download/\
${dict['version']}/htslib-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
