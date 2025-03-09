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
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/c-ares/c-ares/releases/download/\
v${dict['version']}/c-ares-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake_build_args=(
        '--bin-dir=bin'
        '--include-dir=include'
        '--lib-dir=lib'
        "--prefix=${dict['prefix']}"
    )
    koopa_cmake_build "${cmake_build_args[@]}"
    return 0
}
