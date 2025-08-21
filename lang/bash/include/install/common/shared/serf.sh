#!/usr/bin/env bash

main() {
    # """
    # Install Apache Serf.
    # @note Updated 2023-10-09.
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
    koopa_activate_app --build-only 'patch' 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'apr' \
        'apr-util' \
        'openssl' \
        'scons'
    app['patch']="$(koopa_locate_patch)"
    app['scons']="$(koopa_locate_scons)"
    koopa_assert_is_executable "${app[@]}"
    dict['apr']="$(koopa_app_prefix 'apr')"
    dict['apu']="$(koopa_app_prefix 'apr-util')"
    dict['cflags']="${CFLAGS:-}"
    dict['linkflags']="${LDFLAGS:-}"
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['url']="https://www.apache.org/dist/serf/\
serf-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Patch diff created with:
    # > diff -u 'SConstruct-1' 'SConstruct-2' > 'patch-sconstruct.patch'
    dict['patch_file']='patch-sconstruct.patch'
    read -r -d '' "dict[patch_string]" << END || true
--- SConstruct-1	2022-07-13 08:33:39.000000000 -0400
+++ SConstruct-2	2022-07-13 08:34:21.000000000 -0400
@@ -372,6 +372,8 @@

   env.Append(CPPPATH=['\$OPENSSL/include'])
   env.Append(LIBPATH=['\$OPENSSL/lib'])
+  env.Append(CPPPATH=['\$ZLIB/include'])
+  env.Append(LIBPATH=['\$ZLIB/lib'])


 # If build with gssapi, get its information and define SERF_HAVE_GSSAPI
END
    koopa_write_string \
        --file="${dict['patch_file']}" \
        --string="${dict['patch_string']}"
    "${app['patch']}" \
        --unified \
        --verbose \
        'SConstruct' \
        "${dict['patch_file']}"
    scons_args=(
        "APR=${dict['apr']}"
        "APU=${dict['apu']}"
        "CFLAGS=${dict['cflags']}"
        "LIBDIR=${dict['prefix']}/lib"
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
