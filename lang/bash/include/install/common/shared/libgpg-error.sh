#!/usr/bin/env bash

main() {
    # """
    # Install libgpg-error.
    # @note Updated 2023-05-08.
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    dict['gcrypt_url']="$(_koopa_gcrypt_url)"
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
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
