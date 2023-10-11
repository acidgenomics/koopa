#!/usr/bin/env bash

main() {
    # """
    # Install LAPACK.
    # @note Updated 2023-10-11.
    #
    # @seealso
    # - https://www.netlib.org/lapack/
    # - https://github.com/Reference-LAPACK/lapack
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lapack.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_is_macos && koopa_activate_app 'gcc'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    # Temporary fix for 3.11.0 download link.
    case "${dict['version']}" in
        '3.11.0')
            dict['version']='3.11'
            ;;
    esac
    dict['url']="https://github.com/Reference-LAPACK/lapack/archive/refs/tags/\
v${dict['version']}.tar.gz"
    cmake_args=(
        '-DBUILD_SHARED_LIBS=ON'
        '-DLAPACKE=ON'
    )
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
