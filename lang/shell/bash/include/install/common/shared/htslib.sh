#!/usr/bin/env bash

# FIXME htslib requires lzma.

main() {
    # """
    # Install htslib.
    # @note Updated 2023-04-04.
    #
    # @seealso
    # - https://github.com/samtools/htslib/
    # """
    local app conf_args deps
    local -A app dict
    koopa_activate_app --build-only 'make'
    deps=(
        'bzip2'
        'curl'
        'libdeflate'
        'openssl3'
        'xz'
        'zlib'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/samtools/htslib/releases/download/\
${dict['version']}/htslib-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-gcs'
        '--enable-libcurl'
        '--enable-plugins'
        '--enable-s3'
        '--with-libdeflate'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[@]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
