#!/usr/bin/env bash

# NOTE Include support for popt here.

main() {
    # """
    # Install rsync.
    # @note Updated 2025-05-12.
    #
    # @seealso
    # - https://download.samba.org/pub/rsync/INSTALL
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # - https://download.samba.org/pub/rsync/NEWS
    # - https://bugs.gentoo.org/729186
    # """
    local -A dict
    local -a conf_args deps
    deps=(
        'zlib'
        'zstd'
        'lz4'
        'openssl'
        'xxhash'
    )
    koopa_activate_app  "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--enable-ipv6'
        '--enable-lz4'
        '--enable-openssl'
        '--enable-xxhash'
        "--prefix=${dict['prefix']}"
        '--with-included-popt=no'
        '--with-included-zlib=no'
    )
    if koopa_is_macos
    then
        conf_args+=('--disable-zstd')
    else
        conf_args+=('--enable-zstd')
    fi
# >     dict['url']="https://rsync.samba.org/ftp/rsync/\
# > rsync-${dict['version']}.tar.gz"
    dict['url']="https://www.mirrorservice.org/sites/rsync.samba.org/\
rsync-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
