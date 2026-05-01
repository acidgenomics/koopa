#!/usr/bin/env bash

main() {
    # """
    # Install c-ares.
    # @note Updated 2025-03-08.
    #
    # @seealso
    # - https://c-ares.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/c-ares.rb
    # """
    local -A dict
    local -a cmake_build_args
    _koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/c-ares/c-ares/releases/download/\
v${dict['version']}/c-ares-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    cmake_build_args=(
        '--bin-dir=bin'
        '--include-dir=include'
        '--lib-dir=lib'
        "--prefix=${dict['prefix']}"
    )
    _koopa_cmake_build "${cmake_build_args[@]}"
    return 0
}
