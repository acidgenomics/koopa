#!/usr/bin/env bash

main() {
    # """
    # Install libarchive.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/libarchive.rb
    # """
    local -A app dict
    local -a conf_args deps
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    deps=(
        # > 'libb2'
        'bzip2'
        'expat'
        'lz4'
        'xz'
        'zlib'
        'zstd'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='libarchive'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://www.libarchive.org/downloads/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Fix for breaking change introduced in 3.6.2.
    koopa_find_and_replace_in_file \
        --pattern='Requires.private: @LIBSREQUIRED@' \
        --replacement='' \
        'build/pkgconfig/libarchive.pc.in'
    conf_args=(
        # > '--with-expat'
        "--prefix=${dict['prefix']}"
        '--without-lzma'
        '--without-lzo2'
        '--without-nettle'
        '--without-openssl'
        '--without-xml2'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
