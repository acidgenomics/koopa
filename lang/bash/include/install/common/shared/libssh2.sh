#!/usr/bin/env bash

# NOTE Consider switching to CMake build approach. Refer to conda-forge
# recipe for details.

main() {
    # """
    # Install libssh2.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/conda-forge/libssh2-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libssh2.rb
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'zlib' 'openssl'
    dict['openssl']="$(_koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    conf_args=(
        '--disable-examples-build'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
        '--with-crypto=openssl'
        "--with-libssl-prefix=${dict['openssl']}"
        "--with-libz-prefix=${dict['zlib']}"
    )
    dict['url']="https://www.libssh2.org/download/\
libssh2-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
