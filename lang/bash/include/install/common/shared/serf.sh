#!/usr/bin/env bash

main() {
    # """
    # Install Apache Serf.
    # @note Updated 2023-06-12.
    #
    # Required by subversion for HTTPS connections.
    # Refer to 'SConstruct' file for supported 'scons' arguments.
    #
    # @seealso
    # - https://serf.apache.org/download
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     subversion.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/serf.html
    # - https://github.com/apache/serf/blob/trunk/README
    # """
    local -A app dict
    local -a scons_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'apr' \
        'apr-util' \
        'openssl3' \
        'scons'
    app['cat']="$(koopa_locate_cat)"
    app['scons']="$(koopa_locate_scons)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://www.apache.org/dist/serf/\
serf-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    dict['apr']="$(koopa_app_prefix 'apr')"
    dict['apu']="$(koopa_app_prefix 'apr-util')"
    dict['cflags']="${CFLAGS:-}"
    dict['libdir']="${dict['prefix']}/lib"
    dict['linkflags']="${LDFLAGS:-}"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    scons_args=(
        "APR=${dict['apr']}"
        "APU=${dict['apu']}"
        "CFLAGS=${dict['cflags']}"
        "LIBDIR=${dict['libdir']}"
        "LINKFLAGS=${dict['linkflags']}"
        "OPENSSL=${dict['openssl']}"
        "PREFIX=${dict['prefix']}"
        "ZLIB=${dict['zlib']}"
    )
    "${app['scons']}" "${scons_args[@]}"
    "${app['scons']}" "${scons_args[@]}" install
    koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
