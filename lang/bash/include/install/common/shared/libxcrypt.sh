#!/usr/bin/env bash

main() {
    # """
    # Install libxcrypt.
    # @note Updated 2025-02-11.
    #
    # @seealso
    # - https://github.com/conda-forge/libxcrypt-feedstock
    # - https://formulae.brew.sh/formula/libxcrypt
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
        "--prefix=${dict['prefix']}"
        '--disable-failure-tokens'
        '--disable-static'
        '--enable-hashes=strong,glibc'
        # > '--disable-obsolete-api'
        # > '--disable-valgrind'
        # > '--disable-xcrypt-compat-files'
    )
    koopa_make_build "${conf_args[@]}"
    return 0
}
