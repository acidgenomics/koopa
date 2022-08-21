#!/usr/bin/env bash

# When zstd is enabled, we're hitting these errors on macOS:
#
# In file included from cleanup.c:23:
# ./rsync.h:604:3: error: Could not find a 32-bit integer variable
# # error Could not find a 32-bit integer variable
# ./rsync.h:673:2: error: unknown type name 'int32'
#         int32 size, entries;
# ./rsync.h:674:8: error: expected ';' at end of declaration list
#         uint32 node_size;

main() {
    # """
    # Install rsync.
    # @note Updated 2022-08-11.
    #
    # @seealso
    # - https://download.samba.org/pub/rsync/INSTALL
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # - https://download.samba.org/pub/rsync/NEWS
    # - https://bugs.gentoo.org/729186
    # """
    local app deps dict
    koopa_assert_has_no_args "$#"
    deps=()
    if koopa_is_linux
    then
        deps+=('zstd')
    fi
    deps+=(
        'zlib'
        'lz4'
        'openssl3'
        'xxhash'
    )
    koopa_activate_opt_prefix  "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='rsync'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://download.samba.org/pub/${dict['name']}/src/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
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
    # > ./prepare-source
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
