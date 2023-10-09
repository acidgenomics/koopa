#!/usr/bin/env bash

main() {
    # """
    # Install libgcrypt.
    # @note Updated 2023-06-12.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     libgcrypt.rb
    #
    # - https://dev.gnupg.org/T6442
    # """
    local -A app dict
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'libgpg-error'
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['patch']="$(koopa_locate_patch)"
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        # > '--disable-static'
        '--disable-asm'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        "--with-libgpg-error-prefix=${dict['libgpg_error']}"
    )
    dict['url']="${dict['gcrypt_url']}/libgcrypt/\
libgcrypt-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    # Patch from Homebrew recipe.
    # FIXME Rework to not require cat here.
    "${app['cat']}" << END > 'rndgetentropy.patch'
index 513da0b..d8eedce 100644
--- a/random/rndgetentropy.c
+++ b/random/rndgetentropy.c
@@ -81,27 +81,8 @@ _gcry_rndgetentropy_gather_random (void (*add)(const void*, size_t,
       do
         {
           _gcry_pre_syscall ();
-          if (fips_mode ())
-            {
-              /* DRBG chaining defined in SP 800-90A (rev 1) specify
-               * the upstream (kernel) DRBG needs to be reseeded for
-               * initialization of downstream (libgcrypt) DRBG. For this
-               * in RHEL, we repurposed the GRND_RANDOM flag of getrandom API.
-               * The libgcrypt DRBG is initialized with 48B of entropy, but
-               * the kernel can provide only 32B at a time after reseeding
-               * so we need to limit our requests to 32B here.
-               * This is clarified in IG 7.19 / IG D.K. for FIPS 140-2 / 3
-               * and might not be applicable on other FIPS modules not running
-               * RHEL kernel.
-               */
-              nbytes = length < 32 ? length : 32;
-              ret = getrandom (buffer, nbytes, GRND_RANDOM);
-            }
-          else
-            {
-              nbytes = length < sizeof (buffer) ? length : sizeof (buffer);
-              ret = getentropy (buffer, nbytes);
-            }
+          nbytes = length < sizeof (buffer) ? length : sizeof (buffer);
+          ret = getentropy (buffer, nbytes);
           _gcry_post_syscall ();
         }
       while (ret == -1 && errno == EINTR);
END
    "${app['patch']}" \
        --unified \
        --verbose \
        'src/random/rndgetentropy.c' \
        'rndgetentropy.patch'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
