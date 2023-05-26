#!/usr/bin/env bash

main() {
    # """
    # Install libfido2.
    # @note Updated 2023-05-26.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libfido2
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/besser82/libxcrypt/releases/download/\
v${dict['version']}/libxcrypt-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args=(
        '--disable-failure-tokens'
        '--disable-obsolete-api'
        '--disable-static'
        '--disable-valgrind'
        '--disable-xcrypt-compat-files'
        "--prefix=${dict['prefix']}"
    )
    koopa_make_build "${conf_args[@]}"
    return 0
}
