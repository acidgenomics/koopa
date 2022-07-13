#!/usr/bin/env bash

# FIXME Can we use CMake here instead with CMakeList.txt reference?
# FIXME Failing to locate 'zlib.h' inside of Ubuntu here.

main() {
    # """
    # Install Apache Serf.
    # @note Updated 2022-07-12.
    #
    # Required by subversion for HTTPS connections.
    #
    # @seealso
    # - https://serf.apache.org/download
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     subversion.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/serf.html
    # - https://github.com/apache/serf/blob/trunk/README
    # - https://fossies.org/diffs/serf/1.3.8_vs_1.3.9/README-diff.html
    # - https://www.howtogeek.com/415442/
    #     how-to-apply-a-patch-to-a-file-and-create-patches-in-linux/
    # - https://docs.moodle.org/dev/How_to_create_a_patch
    # - https://docs.moodle.org/dev/How_to_apply_a_patch
    # """
    local app dict scons_args
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'patch'
    if koopa_is_linux
    then
        koopa_activate_opt_prefix 'zlib'
    fi
    koopa_activate_opt_prefix \
        'apr' \
        'apr-util' \
        'openssl1' \
        'scons'
    declare -A app=(
        [patch]="$(koopa_locate_patch)"
        [scons]="$(koopa_locate_scons)"
    )
    [[ -x "${app[patch]}" ]] || return 1
    [[ -x "${app[scons]}" ]] || return 1
    declare -A dict=(
        [name]='serf'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://www.apache.org/dist/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # Patch diff created with:
    # > diff -Naur 'SConstruct' 'SConstruct-1' > 'sconstruct-1.patch'
    cat << END > 'sconstruct-1.patch'
--- SConstruct	2022-07-13 07:51:34.000000000 -0400
+++ SConstruct-1	2022-07-13 07:51:14.000000000 -0400
@@ -152,7 +152,7 @@
                  True),
     )
 
-env = Environment(variables=opts,
+env = Environment(variables=opts, RPATHPREFIX = '-Wl,-rpath,',
                   tools=('default', 'textfile',),
                   CPPPATH=['.', ],
                   )
@@ -183,7 +183,7 @@
 
 unknown = opts.UnknownVariables()
 if unknown:
-  print 'Warning: Used unknown variables:', ', '.join(unknown.keys())
+  print('Warning: Used unknown variables:', ', '.join(unknown.keys()))
 
 apr = str(env['APR'])
 apu = str(env['APU'])
END
    "${app[patch]}" -u 'SConstruct' -i 'sconstruct-1.patch'
    if koopa_is_linux
    then
        # Patch diff created with:
        # > diff -Naur 'SConstruct-1' 'SConstruct-2' > 'sconstruct-2.patch'
        cat << END > 'sconstruct-2.patch'
--- SConstruct-1	2022-07-13 07:51:14.000000000 -0400
+++ SConstruct-2	2022-07-13 07:53:59.000000000 -0400
@@ -372,6 +372,8 @@
 
   env.Append(CPPPATH=['$OPENSSL/include'])
   env.Append(LIBPATH=['$OPENSSL/lib'])
+  env.Append(CPPPATH=['$ZLIB\/include'])
+  env.Append(LIBPATH=['$ZLIB/lib'])
 
 
 # If build with gssapi, get its information and define SERF_HAVE_GSSAPI
END
        "${app[patch]}" -u 'SConstruct' 'sconstruct-2.patch'
    fi
    # Refer to 'SConstruct' file for supported arguments.
    scons_args=(
        # > 'CC=gcc'
        # > "LIBS=${LD_LIBRARY_PATH:-}"
        "APR=${dict[opt_prefix]}/apr"
        "APU=${dict[opt_prefix]}/apr-util"
        "CFLAGS=${CFLAGS:-}"
        'LIBDIR=lib'
        "LINKFLAGS=${LDFLAGS:-}"
        "OPENSSL=${dict[opt_prefix]}/openssl1"
        "PREFIX=${dict[prefix]}"
    )
    if koopa_is_linux
    then
        scons_args+=(
            "ZLIB=${dict[opt_prefix]}/zlib"
        )
    fi
    "${app[scons]}" "${scons_args[@]}"
    "${app[scons]}" "${scons_args[@]}" install
    return 0
}
