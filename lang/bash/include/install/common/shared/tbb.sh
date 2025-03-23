#!/usr/bin/env bash

main() {
    # """
    # Install TBB.
    # @note Updated 2023-08-04.
    #
    # @seealso
    # - https://github.com/oneapi-src/oneTBB
    # - https://github.com/conda-forge/tbb-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/tbb.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DBUILD_SHARED_LIBS=ON'
        '-DTBB4PY_BUILD=OFF'
        '-DTBB_TEST=OFF'
    )
    dict['url']="https://github.com/oneapi-src/oneTBB/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build \
        --jobs=1 \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
