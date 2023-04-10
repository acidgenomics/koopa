#!/usr/bin/env bash

# FIXME Include support for popt here.

main() {
    # """
    # Install rsync.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://download.samba.org/pub/rsync/INSTALL
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # - https://download.samba.org/pub/rsync/NEWS
    # - https://bugs.gentoo.org/729186
    # """
    local -A app dict
    local -a deps
    koopa_activate_app --build-only 'make'
    deps=(
        'zlib'
        'zstd'
        'lz4'
        'openssl3'
        'xxhash'
    )
    koopa_activate_app  "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://download.samba.org/pub/rsync/src/\
rsync-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--enable-ipv6'
        '--enable-lz4'
        '--enable-openssl'
        '--enable-xxhash'
        '--with-included-popt=no'
        '--with-included-zlib=no'
    )
    if koopa_is_macos
    then
        conf_args+=('--disable-zstd')
    else
        conf_args+=('--enable-zstd')
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    # > ./prepare-source
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
