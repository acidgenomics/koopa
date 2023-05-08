#!/usr/bin/env bash

main() {
    # """
    # Install libgpg-error.
    # @note Updated 2023-05-08.
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['gcrypt_url']="$(koopa_gcrypt_url)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-install-gpg-error-config'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="${dict['gcrypt_url']}/libgpg-error/\
libgpg-error-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
