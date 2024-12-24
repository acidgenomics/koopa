#!/usr/bin/env bash

main() {
    # """
    # Install libassuan.
    # @note Updated 2024-12-24.
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'libgpg-error'
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['libgpg_error']="$(koopa_app_prefix 'libgpg-error')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        "--with-libgpg-error-prefix=${dict['libgpg_error']}"
    )
    # Fixes duplicate symbols errors
    # https://lists.gnupg.org/pipermail/gnupg-devel/2024-July/035614.html
    koopa_append_cflags '-std=gnu89'
    dict['url']="${dict['gcrypt_url']}/libassuan/\
libassuan-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
