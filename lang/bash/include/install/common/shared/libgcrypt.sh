#!/usr/bin/env bash

main() {
    # """
    # Install libgcrypt.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libgcrypt
    # """
    local -A dict
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'libgpg-error'
    dict['gcrypt_url']="$(_koopa_gcrypt_url)"
    dict['libgpg_error']="$(_koopa_app_prefix 'libgpg-error')"
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
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
