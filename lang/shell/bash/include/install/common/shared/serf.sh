#!/usr/bin/env bash
# koopa nolint=line-width

main() {
    # """
    # Install Apache Serf.
    # @note Updated 2023-04-06.
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
    local -A app dict
    local -a scons_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'patch' 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'apr' \
        'apr-util' \
        'openssl3' \
        'scons'
    app['cat']="$(koopa_locate_cat)"
    app['patch']="$(koopa_locate_patch)"
    app['scons']="$(koopa_locate_scons)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='serf'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://www.apache.org/dist/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Patch diff created with:
    # > diff -u 'SConstruct' 'SConstruct-1' > 'patch-sconstruct-1.patch'
    "${app['cat']}" << END > 'patch-sconstruct-1.patch'
--- SConstruct	2022-07-13 08:31:30.000000000 -0400
+++ SConstruct-1	2022-07-13 08:33:39.000000000 -0400
@@ -152,7 +152,7 @@
                  True),
     )

-env = Environment(variables=opts,
+env = Environment(variables=opts, RPATHPREFIX = '-Wl,-rpath,',
                   tools=('default', 'textfile',),
                   CPPPATH=['.', ],
                   )
@@ -163,9 +163,9 @@
               suffix='.def', src_suffix='.h')
   })

-match = re.search('SERF_MAJOR_VERSION ([0-9]+).*'
-                  'SERF_MINOR_VERSION ([0-9]+).*'
-                  'SERF_PATCH_VERSION ([0-9]+)',
+match = re.search(b'SERF_MAJOR_VERSION ([0-9]+).*'
+                  b'SERF_MINOR_VERSION ([0-9]+).*'
+                  b'SERF_PATCH_VERSION ([0-9]+)',
                   env.File('serf.h').get_contents(),
                   re.DOTALL)
 MAJOR, MINOR, PATCH = [int(x) for x in match.groups()]
@@ -183,7 +183,7 @@

 unknown = opts.UnknownVariables()
 if unknown:
-  print 'Warning: Used unknown variables:', ', '.join(unknown.keys())
+  print('Warning: Used unknown variables:', ', '.join(unknown.keys()))

 apr = str(env['APR'])
 apu = str(env['APU'])
END
    "${app['patch']}" \
        --unified \
        --verbose \
        'SConstruct' \
        'patch-sconstruct-1.patch'
    if koopa_is_linux
    then
        # Patch diff created with:
        # > diff -u 'SConstruct-1' 'SConstruct-2' > 'patch-sconstruct-2.patch'
        "${app['cat']}" << END > 'patch-sconstruct-2.patch'
--- SConstruct-1	2022-07-13 08:33:39.000000000 -0400
+++ SConstruct-2	2022-07-13 08:34:21.000000000 -0400
@@ -372,6 +372,8 @@

   env.Append(CPPPATH=['\$OPENSSL/include'])
   env.Append(LIBPATH=['\$OPENSSL/lib'])
+  env.Append(CPPPATH=['\$ZLIB/include'])
+  env.Append(LIBPATH=['\$ZLIB/lib'])


 # If build with gssapi, get its information and define SERF_HAVE_GSSAPI
END
        "${app['patch']}" \
            --unified \
            --verbose \
            'SConstruct' \
            'patch-sconstruct-2.patch'
    fi
    # Apply OpenSSL compatibility patch.
    # https://www.linuxfromscratch.org/patches/blfs/svn/
    #   serf-1.3.9-openssl3_fixes-1.patch
    "${app['cat']}" << END > 'patch-openssl3.patch'
Submitted By:            Douglas R. Reno <renodr at linuxfromscratch dot org>
Date:                    2021-12-30
Initial Package Version: 1.3.9
Origin:                  Fedora Rawhide (https://src.fedoraproject.org/rpms/libserf/tree/rawhide)
Upstream Status:         Merge Request
Description:             Fixes a build error in Subversion caused by serf using
                         internal OpenSSL API functions for it's own use. Also
                         fixes a crash bug that happens due to a return value
                         being invalid.

diff -Naurp serf-1.3.9.orig/buckets/ssl_buckets.c serf-1.3.9/buckets/ssl_buckets.c
--- serf-1.3.9.orig/buckets/ssl_buckets.c	2016-06-30 10:45:07.000000000 -0500
+++ serf-1.3.9/buckets/ssl_buckets.c	2021-12-30 10:56:53.101158440 -0600
@@ -407,7 +407,7 @@ static int bio_bucket_destroy(BIO *bio)

 static long bio_bucket_ctrl(BIO *bio, int cmd, long num, void *ptr)
 {
-    long ret = 1;
+    long ret = 0;

     switch (cmd) {
     default:
@@ -415,6 +415,7 @@ static long bio_bucket_ctrl(BIO *bio, in
         break;
     case BIO_CTRL_FLUSH:
         /* At this point we can't force a flush. */
+        ret = 1;
         break;
     case BIO_CTRL_PUSH:
     case BIO_CTRL_POP:
@@ -1204,6 +1205,10 @@ static void init_ssl_libraries(void)
     }
 }

+#ifndef ERR_GET_FUNC
+#define ERR_GET_FUNC(ec) (0)
+#endif
+
 static int ssl_need_client_cert(SSL *ssl, X509 **cert, EVP_PKEY **pkey)
 {
     serf_ssl_context_t *ctx = SSL_get_app_data(ssl);
END
    "${app['patch']}" \
        --forward \
        --input='patch-openssl3.patch' \
        --strip=1 \
        --verbose
    # Refer to 'SConstruct' file for supported arguments.
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
    return 0
}
